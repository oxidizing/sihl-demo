module type TYPE = sig
  type t
end

module MakeController (Ingredient : Pizza.SERVICE) = struct
  let index index_view req =
    let open Lwt.Syntax in
    let csrf = Sihl.Web.Csrf.find req |> Option.get in
    let alert = Sihl.Web.Flash.find_alert req in
    let notice = Sihl.Web.Flash.find_notice req in
    let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
    let* ingredients = Ingredient.query () in
    Lwt.return
    @@ Sihl.Web.Response.of_html
         (index_view user ~alert ~notice csrf ingredients)
  ;;

  let new' new_view req =
    let open Lwt.Syntax in
    let csrf = Sihl.Web.Csrf.find req |> Option.get in
    let alert = Sihl.Web.Flash.find_alert req in
    let notice = Sihl.Web.Flash.find_notice req in
    let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
    Lwt.return @@ Sihl.Web.Response.of_html (new_view user ~alert ~notice csrf)
  ;;

  let create req =
    let open Lwt.Syntax in
    let* urlencoded = Sihl.Web.Request.to_urlencoded req in
    let ingredient = Conformist.decode Pizza.ingredient_schema urlencoded in
    let result = Conformist.validate Pizza.ingredient_schema urlencoded in
    match ingredient, result with
    | Ok ingredient, [] ->
      let* ingredient =
        Ingredient.create
          ingredient.Pizza.name
          ingredient.Pizza.is_vegan
          ingredient.Pizza.price
      in
      (match ingredient with
      | Ok _ ->
        Sihl.Web.Response.redirect_to "/ingredients"
        |> Sihl.Web.Flash.set_notice (Some "Ingredient added")
        |> Lwt.return
      | Error msg ->
        Sihl.Web.Response.redirect_to "/ingredients"
        |> Sihl.Web.Flash.set_alert (Some msg)
        |> Lwt.return)
    | Error msg, _ ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_alert (Some msg)
      |> Lwt.return
    | Ok _, _ ->
      (* TODO [jerben] render form errors *)
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_alert (Some "Invalid input provided")
      |> Lwt.return
  ;;

  let show show_view req =
    let open Lwt.Syntax in
    let name = Sihl.Web.Router.param req "name" in
    let alert = Sihl.Web.Flash.find_alert req in
    let notice = Sihl.Web.Flash.find_notice req in
    let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
    let* ingredient = Ingredient.find name |> Lwt.map Option.get in
    Lwt.return
    @@ Sihl.Web.Response.of_html (show_view user ~alert ~notice ingredient)
  ;;

  let edit edit_view req =
    let open Lwt.Syntax in
    let name = Sihl.Web.Router.param req "name" in
    let* ingredient = Ingredient.find name |> Lwt.map Option.get in
    let csrf = Sihl.Web.Csrf.find req |> Option.get in
    let alert = Sihl.Web.Flash.find_alert req in
    let notice = Sihl.Web.Flash.find_notice req in
    let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
    Lwt.return
    @@ Sihl.Web.Response.of_html
         (edit_view user ~alert ~notice ~csrf ingredient)
  ;;

  let update req =
    let open Lwt.Syntax in
    let* urlencoded = Sihl.Web.Request.to_urlencoded req in
    let ingredient = Conformist.decode Pizza.ingredient_schema urlencoded in
    let result = Conformist.validate Pizza.ingredient_schema urlencoded in
    match ingredient, result with
    | Ok ingredient, [] ->
      let* ingredient =
        Ingredient.find ingredient.Pizza.name |> Lwt.map Option.get
      in
      let* updated = Ingredient.update ingredient in
      (match updated with
      | Ok _ ->
        Sihl.Web.Response.redirect_to "/ingredients"
        |> Sihl.Web.Flash.set_notice (Some "Ingredient updated")
        |> Lwt.return
      | Error msg ->
        Sihl.Web.Response.redirect_to "/ingredients"
        |> Sihl.Web.Flash.set_alert (Some msg)
        |> Lwt.return)
    | Ok _, _ ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_alert (Some "Invalid ingredient provided")
      |> Lwt.return
    | Error msg, _ ->
      (* TODO [jerben] render form errors *)
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_alert (Some msg)
      |> Lwt.return
  ;;

  let delete' req =
    let open Lwt.Syntax in
    let name = Sihl.Web.Router.param req "name" in
    let* ingredient = Ingredient.find name in
    match ingredient with
    | None ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_notice
           (Some (Format.sprintf "Ingredient '%s' not found" name))
      |> Lwt.return
    | Some ingredient ->
      let* () = Ingredient.delete ingredient in
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_notice (Some "Ingredient removed")
      |> Lwt.return
  ;;
end

let resource
    (type a)
    ~index
    ~new'
    ~show
    ~edit
    name
    (module Service : Pizza.SERVICE with type t = a)
  =
  let module Controller = MakeController (Service) in
  Sihl.Web.
    [ get (Format.sprintf "/%s" name) (Controller.index index)
    ; get (Format.sprintf "/%s/new" name) (Controller.new' new')
    ; post (Format.sprintf "/%s" name) Controller.create
    ; get (Format.sprintf "/%s/:name" name) (Controller.show show)
    ; get (Format.sprintf "/%s/:name/edit" name) (Controller.edit edit)
    ; put (Format.sprintf "/%s/:name" name) Controller.update
    ; delete (Format.sprintf "/%s/:name" name) Controller.delete'
    ]
;;
