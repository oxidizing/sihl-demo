let index req =
  let open Lwt.Syntax in
  let csrf = Sihl.Web.Csrf.find req |> Option.get in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let* ingredients = Pizza.Ingredient.query () in
  Lwt.return
  @@ Sihl.Web.Response.of_html
       (View.Ingredients.index user ~alert ~notice csrf ingredients)
;;

let new' req =
  let open Lwt.Syntax in
  let csrf = Sihl.Web.Csrf.find req |> Option.get in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  Lwt.return
  @@ Sihl.Web.Response.of_html (View.Ingredients.new' user ~alert ~notice csrf)
;;

let create req =
  let open Lwt.Syntax in
  let* urlencoded = Sihl.Web.Request.to_urlencoded req in
  let ingredient = Conformist.decode Pizza.ingredient_schema urlencoded in
  let result = Conformist.validate Pizza.ingredient_schema urlencoded in
  match ingredient, result with
  | Ok ingredient, [] ->
    let* ingredient =
      Pizza.Ingredient.create
        ingredient.Pizza.name
        ingredient.Pizza.is_vegan
        ingredient.Pizza.price
    in
    (match ingredient with
    | Ok ingredient ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_notice
           (Format.sprintf "Ingredient '%s' added" ingredient.Pizza.name)
      |> Lwt.return
    | Error msg ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_alert msg
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

let show req =
  let open Lwt.Syntax in
  let name = Sihl.Web.Router.param req "name" in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let* ingredient = Pizza.Ingredient.find name |> Lwt.map Option.get in
  Lwt.return
  @@ Sihl.Web.Response.of_html
       (View.Ingredients.show user ~alert ~notice ingredient)
;;

let edit req =
  let open Lwt.Syntax in
  let name = Sihl.Web.Router.param req "name" in
  let* ingredient = Pizza.Ingredient.find name |> Lwt.map Option.get in
  let csrf = Sihl.Web.Csrf.find req |> Option.get in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  Lwt.return
  @@ Sihl.Web.Response.of_html
       (View.Ingredients.edit user ~alert ~notice ~csrf ingredient)
;;

let update req =
  let open Lwt.Syntax in
  let* urlencoded = Sihl.Web.Request.to_urlencoded req in
  let ingredient = Conformist.decode Pizza.ingredient_schema urlencoded in
  let result = Conformist.validate Pizza.ingredient_schema urlencoded in
  match ingredient, result with
  | Ok ingredient, [] ->
    let* ingredient =
      Pizza.Ingredient.find ingredient.Pizza.name |> Lwt.map Option.get
    in
    let* updated = Pizza.Ingredient.update ingredient in
    (match updated with
    | Ok updated ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_notice
           (Some (Format.sprintf "Ingredient '%s' updated" updated.Pizza.name))
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

let delete req =
  let open Lwt.Syntax in
  let name = Sihl.Web.Router.param req "name" in
  let* ingredient = Pizza.Ingredient.find name in
  match ingredient with
  | None ->
    Sihl.Web.Response.redirect_to "/ingredients"
    |> Sihl.Web.Flash.set_notice
         (Format.sprintf "Ingredient '%s' not found" name)
    |> Lwt.return
  | Some ingredient ->
    let* () = Pizza.Ingredient.delete ingredient in
    Sihl.Web.Response.redirect_to "/ingredients"
    |> Sihl.Web.Flash.set_notice
         (Format.sprintf "Ingredient '%s' removed" ingredient.Pizza.name)
    |> Lwt.return
;;
