let singularize str =
  Option.value ~default:str (CCString.chop_suffix ~suf:"s" str)
;;

let capitalize = CCString.capitalize_ascii

module Form = struct
  type t = (string * string option * string option) list
  [@@deriving yojson, show]

  let set
      ?(key = "_form")
      (t : Conformist.error list)
      (urlencoded : (string * string list) list)
      resp
    =
    let t =
      List.map
        ~f:(fun (k, v) ->
          t
          |> List.find_opt ~f:(fun (field, _, _) -> String.equal field k)
          |> Option.map (fun (field, input, value) -> field, input, Some value)
          |> Option.value ~default:(k, CCList.head_opt v, None))
        urlencoded
    in
    let json = t |> to_yojson |> Yojson.Safe.to_string in
    Sihl.Web.Flash.set [ key, json ] resp
  ;;

  let find_form ?(key = "_form") req =
    match Sihl.Web.Flash.find key req with
    | None -> []
    | Some json ->
      let yojson =
        try Some (Yojson.Safe.from_string json) with
        | _ -> None
      in
      (match yojson with
      | Some yojson ->
        (match of_yojson yojson with
        | Error _ -> []
        | Ok form -> form)
      | None -> [])
  ;;

  let find (k : string) (form : t) : string option * string option =
    form
    |> List.find_opt ~f:(fun (k', _, _) -> String.equal k k')
    |> Option.map (fun (_, value, error) -> value, error)
    |> Option.value ~default:(None, None)
  ;;
end

module type SERVICE = sig
  type t

  val find : string -> t option Lwt.t
  val query : unit -> t list Lwt.t
  val insert : t -> (t, string) Result.t Lwt.t
  val create : string -> bool -> int -> (t, string) result Lwt.t
  val update : string -> t -> (t, string) result Lwt.t
  val delete : t -> (unit, string) result Lwt.t
end

module type VIEW = sig
  type t

  val index
    :  Rock.Request.t
    -> string
    -> t list
    -> [> Html_types.html ] Tyxml.Html.elt Lwt.t

  val new'
    :  Rock.Request.t
    -> string
    -> Form.t
    -> [> Html_types.html ] Tyxml.Html.elt Lwt.t

  val show : Rock.Request.t -> t -> [> Html_types.html ] Tyxml.Html.elt Lwt.t

  val edit
    :  Rock.Request.t
    -> string
    -> Form.t
    -> t
    -> [> Html_types.html ] Tyxml.Html.elt Lwt.t
end

module type CONTROLLER = sig
  type t

  val index : string -> Rock.Request.t -> Rock.Response.t Lwt.t
  val new' : ?key:string -> string -> Rock.Request.t -> Rock.Response.t Lwt.t

  val create
    :  string
    -> ('a, 'b, t) Conformist.t
    -> Rock.Request.t
    -> Rock.Response.t Lwt.t

  val show : string -> Rock.Request.t -> Rock.Response.t Lwt.t
  val edit : ?key:string -> string -> Rock.Request.t -> Rock.Response.t Lwt.t

  val update
    :  string
    -> ('a, 'b, t) Conformist.t
    -> Rock.Request.t
    -> Rock.Response.t Lwt.t

  val delete' : string -> Rock.Request.t -> Rock.Response.t Lwt.t
end

module MakeController (Service : SERVICE) (View : VIEW with type t = Service.t) =
struct
  exception Exception of string

  type t = Service.t

  let index name req =
    let open Lwt.Syntax in
    let csrf =
      match Sihl.Web.Csrf.find req with
      | None ->
        Logs.err (fun m ->
            m "CSRF middleware not installed for resource '%s'" name);
        raise @@ Exception "CSRF middleware not installed"
      | Some token -> token
    in
    let* things = Service.query () in
    let* html = View.index req csrf things in
    Lwt.return @@ Sihl.Web.Response.of_html html
  ;;

  let new' ?key name req =
    let open Lwt.Syntax in
    let csrf =
      match Sihl.Web.Csrf.find req with
      | None ->
        Logs.err (fun m ->
            m "CSRF middleware not installed for resource '%s'" name);
        raise @@ Exception "CSRF middleware not installed"
      | Some token -> token
    in
    let form = Form.find_form ?key req in
    let* html = View.new' req csrf form in
    Lwt.return @@ Sihl.Web.Response.of_html html
  ;;

  let create name schema req =
    let open Lwt.Syntax in
    let* urlencoded = Sihl.Web.Request.to_urlencoded req in
    let thing = Conformist.decode_and_validate schema urlencoded in
    match thing with
    | Ok thing ->
      let* thing = Service.insert thing in
      (match thing with
      | Ok _ ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
        |> Sihl.Web.Flash.set_notice
             (Format.sprintf "Successfully added %s" (singularize name))
        |> Lwt.return
      | Error msg ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s/new" name)
        |> Form.set [] urlencoded
        |> Sihl.Web.Flash.set_alert msg
        |> Lwt.return)
    | Error errors ->
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s/new" name)
      |> Sihl.Web.Flash.set_alert "Some of the input is invalid"
      |> Form.set errors urlencoded
      |> Lwt.return
  ;;

  let show name req =
    let open Lwt.Syntax in
    let id = Sihl.Web.Router.param req "id" in
    let* thing = Service.find id in
    match thing with
    | Some thing ->
      let* html = View.show req thing in
      Lwt.return @@ Sihl.Web.Response.of_html html
    | None ->
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
      |> Sihl.Web.Flash.set_alert
           (Format.sprintf
              "%s with id '%s' not found"
              (singularize (capitalize name))
              id)
      |> Lwt.return
  ;;

  let edit ?key name req =
    let open Lwt.Syntax in
    let id = Sihl.Web.Router.param req "id" in
    let* thing = Service.find id in
    match thing with
    | Some thing ->
      let csrf =
        match Sihl.Web.Csrf.find req with
        | None ->
          Logs.err (fun m ->
              m "CSRF middleware not installed for resource '%s'" name);
          raise @@ Exception "CSRF middleware not installed"
        | Some token -> token
      in
      let form = Form.find_form ?key req in
      let* html = View.edit req csrf form thing in
      Lwt.return @@ Sihl.Web.Response.of_html html
    | None ->
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
      |> Sihl.Web.Flash.set_alert
           (Format.sprintf
              "%s with id '%s' not found"
              (singularize (capitalize name))
              id)
      |> Lwt.return
  ;;

  let update name schema req =
    let open Lwt.Syntax in
    let* urlencoded = Sihl.Web.Request.to_urlencoded req in
    let thing = Conformist.decode_and_validate schema urlencoded in
    let id = Sihl.Web.Router.param req "id" in
    match thing with
    | Ok thing ->
      let* updated = Service.update id thing in
      (match updated with
      | Ok _ ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s/%s" name id)
        |> Sihl.Web.Flash.set_notice
             (Format.sprintf "Successfully updated %s" (singularize name))
        |> Lwt.return
      | Error msg ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s/%s/edit" name id)
        |> Sihl.Web.Flash.set_alert msg
        |> Form.set [] urlencoded
        |> Lwt.return)
    | Error errors ->
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s/%s/edit" name id)
      |> Sihl.Web.Flash.set_alert "Some of the input is invalid"
      |> Form.set errors urlencoded
      |> Lwt.return
  ;;

  let delete' name req =
    let open Lwt.Syntax in
    let id = Sihl.Web.Router.param req "id" in
    let* thing = Service.find id in
    match thing with
    | None ->
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
      |> Sihl.Web.Flash.set_alert
           (Format.sprintf
              "%s with id '%s' not found"
              (singularize (capitalize name))
              id)
      |> Lwt.return
    | Some thing ->
      let* result = Service.delete thing in
      (match result with
      | Ok () ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
        |> Sihl.Web.Flash.set_notice
             (Format.sprintf
                "Successfully deleted %s '%s'"
                (singularize name)
                id)
        |> Lwt.return
      | Error msg ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
        |> Sihl.Web.Flash.set_notice
             (Format.sprintf "Failed to delete %s: '%s'" (singularize name) msg)
        |> Lwt.return)
  ;;
end

type action =
  [ `Index
  | `Create
  | `New
  | `Edit
  | `Show
  | `Update
  | `Destroy
  ]

let router_of_action
    (type a)
    (module Controller : CONTROLLER with type t = a)
    name
    schema
    (action : action)
  =
  match action with
  | `Index -> Sihl.Web.get (Format.sprintf "/%s" name) (Controller.index name)
  | `Create ->
    Sihl.Web.post (Format.sprintf "/%s" name) (Controller.create name schema)
  | `New -> Sihl.Web.get (Format.sprintf "/%s/new" name) (Controller.new' name)
  | `Edit ->
    Sihl.Web.get (Format.sprintf "/%s/:id/edit" name) (Controller.edit name)
  | `Show -> Sihl.Web.get (Format.sprintf "/%s/:id" name) (Controller.show name)
  | `Update ->
    Sihl.Web.put (Format.sprintf "/%s/:id" name) (Controller.update name schema)
  | `Destroy ->
    Sihl.Web.delete (Format.sprintf "/%s/:id" name) (Controller.delete' name)
;;

let routers_of_actions
    (type a)
    name
    schema
    (module Controller : CONTROLLER with type t = a)
    (actions : action list)
  =
  let rec create_routers
      (actions : action list)
      (routers : Sihl.Web.router list)
    =
    match actions with
    | action :: (rest : action list) ->
      let router = router_of_action (module Controller) name schema action in
      let routers = List.cons router routers in
      create_routers rest routers
    | [] -> routers
  in
  List.rev (create_routers actions [])
;;

let resource
    (type a)
    ?only:actions
    name
    schema
    (module Service : SERVICE with type t = a)
    (module View : VIEW with type t = a)
  =
  let module Controller = MakeController (Service) (View) in
  match actions with
  | None ->
    routers_of_actions
      name
      schema
      (module Controller)
      [ `Index; `Create; `New; `Edit; `Show; `Update; `Destroy ]
  | Some actions -> routers_of_actions name schema (module Controller) actions
;;
