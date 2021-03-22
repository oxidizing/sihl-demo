let singularize = CCString.drop_while (fun char -> not (Char.equal 's' char))
let capitalize = CCString.capitalize_ascii

module type SERVICE = sig
  type t

  val find : string -> t option Lwt.t
  val query : unit -> t list Lwt.t
  val insert : t -> (t, string) Result.t Lwt.t
  val create : string -> bool -> int -> (t, string) result Lwt.t
  val update : string -> t -> (t, string) result Lwt.t
  val delete : t -> unit Lwt.t
end

module type VIEW = sig
  type t

  val index
    :  Rock.Request.t
    -> string option * string option
    -> string
    -> t list
    -> [> Html_types.html ] Tyxml.Html.elt Lwt.t

  val new'
    :  Rock.Request.t
    -> string option * string option
    -> string
    -> [> Html_types.html ] Tyxml.Html.elt Lwt.t

  val show
    :  Rock.Request.t
    -> string option * string option
    -> t
    -> [> Html_types.html ] Tyxml.Html.elt Lwt.t

  val edit
    :  Rock.Request.t
    -> string option * string option
    -> string
    -> t
    -> [> Html_types.html ] Tyxml.Html.elt Lwt.t
end

module MakeController
    (Service : SERVICE)
    (Resource : VIEW with type t = Service.t) =
struct
  let index _ req =
    let open Lwt.Syntax in
    let csrf = Sihl.Web.Csrf.find req |> Option.get in
    let alert = Sihl.Web.Flash.find_alert req in
    let notice = Sihl.Web.Flash.find_notice req in
    let* things = Service.query () in
    let* html = Resource.index req (alert, notice) csrf things in
    Lwt.return @@ Sihl.Web.Response.of_html html
  ;;

  let new' _ req =
    let open Lwt.Syntax in
    let csrf = Sihl.Web.Csrf.find req |> Option.get in
    let alert = Sihl.Web.Flash.find_alert req in
    let notice = Sihl.Web.Flash.find_notice req in
    let* html = Resource.new' req (alert, notice) csrf in
    Lwt.return @@ Sihl.Web.Response.of_html html
  ;;

  let create name schema req =
    let open Lwt.Syntax in
    let* urlencoded = Sihl.Web.Request.to_urlencoded req in
    let thing = Conformist.decode schema urlencoded in
    let result = Conformist.validate schema urlencoded in
    match thing, result with
    | Ok thing, [] ->
      let* thing = Service.insert thing in
      (match thing with
      | Ok _ ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
        |> Sihl.Web.Flash.set_notice (Some "Successfully added")
        |> Lwt.return
      | Error msg ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
        |> Sihl.Web.Flash.set_alert (Some msg)
        |> Lwt.return)
    | Error msg, _ ->
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
      |> Sihl.Web.Flash.set_alert (Some msg)
      |> Lwt.return
    | Ok _, _ ->
      (* TODO [jerben] render form errors *)
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
      |> Sihl.Web.Flash.set_alert (Some "Invalid input provided")
      |> Lwt.return
  ;;

  let show _ req =
    let open Lwt.Syntax in
    let id = Sihl.Web.Router.param req "id" in
    let alert = Sihl.Web.Flash.find_alert req in
    let notice = Sihl.Web.Flash.find_notice req in
    let* thing = Service.find id |> Lwt.map Option.get in
    let* html = Resource.show req (alert, notice) thing in
    Lwt.return @@ Sihl.Web.Response.of_html html
  ;;

  let edit _ req =
    let open Lwt.Syntax in
    let id = Sihl.Web.Router.param req "id" in
    let* thing = Service.find id |> Lwt.map Option.get in
    let csrf = Sihl.Web.Csrf.find req |> Option.get in
    let alert = Sihl.Web.Flash.find_alert req in
    let notice = Sihl.Web.Flash.find_notice req in
    let* html = Resource.edit req (alert, notice) csrf thing in
    Lwt.return @@ Sihl.Web.Response.of_html html
  ;;

  let update name schema req =
    let open Lwt.Syntax in
    let* urlencoded = Sihl.Web.Request.to_urlencoded req in
    let thing = Conformist.decode schema urlencoded in
    let result = Conformist.validate schema urlencoded in
    let id = Sihl.Web.Router.param req "id" in
    match thing, result with
    | Ok thing, [] ->
      let* updated = Service.update id thing in
      (match updated with
      | Ok _ ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
        |> Sihl.Web.Flash.set_notice (Some "Successfully updated")
        |> Lwt.return
      | Error msg ->
        Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
        |> Sihl.Web.Flash.set_alert (Some msg)
        |> Lwt.return)
    | Ok _, _ ->
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
      |> Sihl.Web.Flash.set_alert (Some "Invalid values provided")
      |> Lwt.return
    | Error msg, _ ->
      (* TODO [jerben] render form errors *)
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
      |> Sihl.Web.Flash.set_alert (Some msg)
      |> Lwt.return
  ;;

  let delete' name req =
    let open Lwt.Syntax in
    let id = Sihl.Web.Router.param req "id" in
    let* thing = Service.find id in
    match thing with
    | None ->
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
      |> Sihl.Web.Flash.set_notice
           (Some (Format.sprintf "Id '%s' not found" id))
      |> Lwt.return
    | Some thing ->
      let* () = Service.delete thing in
      Sihl.Web.Response.redirect_to (Format.sprintf "/%s" name)
      |> Sihl.Web.Flash.set_notice (Some "Successfully removed")
      |> Lwt.return
  ;;
end

let resource
    (type a)
    name
    schema
    (module Service : SERVICE with type t = a)
    (module View : VIEW with type t = a)
  =
  let module Controller = MakeController (Service) (View) in
  Sihl.Web.
    [ get (Format.sprintf "/%s" name) (Controller.index name)
    ; get (Format.sprintf "/%s/new" name) (Controller.new' name)
    ; post (Format.sprintf "/%s" name) (Controller.create name schema)
    ; get (Format.sprintf "/%s/:id" name) (Controller.show name)
    ; get (Format.sprintf "/%s/:id/edit" name) (Controller.edit name)
    ; put (Format.sprintf "/%s/:id" name) (Controller.update name schema)
    ; delete (Format.sprintf "/%s/:id" name) (Controller.delete' name)
    ]
;;
