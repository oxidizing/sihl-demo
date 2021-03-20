let index req =
  let open Lwt.Syntax in
  let csrf = Sihl.Web.Csrf.find req |> Option.get in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let* ingredients = Pizza.find_ingredients () in
  Lwt.return
  @@ Sihl.Web.Response.of_html
       (View.Ingredients.index user ~alert ~notice csrf ingredients)
;;

let new_ req =
  let open Lwt.Syntax in
  let csrf = Sihl.Web.Csrf.find req |> Option.get in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  Lwt.return
  @@ Sihl.Web.Response.of_html (View.Ingredients.new_ user ~alert ~notice csrf)
;;

let create req =
  let open Lwt.Syntax in
  let* name = Sihl.Web.Request.urlencoded "name" req in
  let* is_vegan = Sihl.Web.Request.urlencoded "is_vegan" req in
  let* price = Sihl.Web.Request.urlencoded "price" req in
  match name, is_vegan, price with
  | Some name, Some is_vegan, Some price ->
    let* ingredient =
      Pizza.create_ingredient
        name
        (bool_of_string is_vegan)
        (int_of_string price)
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
  | _ ->
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
  let* ingredient = Pizza.find_ingredient name |> Lwt.map Option.get in
  Lwt.return
  @@ Sihl.Web.Response.of_html
       (View.Ingredients.show user ~alert ~notice ingredient)
;;

let edit req =
  let open Lwt.Syntax in
  let name = Sihl.Web.Router.param req "name" in
  let* ingredient = Pizza.find_ingredient name |> Lwt.map Option.get in
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
  let* name = Sihl.Web.Request.urlencoded "name" req in
  let* is_vegan = Sihl.Web.Request.urlencoded "is_vegan" req in
  let* price = Sihl.Web.Request.urlencoded "price" req in
  match name, is_vegan, price with
  | Some name, Some is_vegan, Some price ->
    let* ingredient = Pizza.find_ingredient name |> Lwt.map Option.get in
    let is_vegan = bool_of_string is_vegan in
    let price = int_of_string price in
    let updated = Pizza.{ ingredient with is_vegan; price } in
    let* updated = Pizza.update_ingredient updated in
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
  | _ ->
    Sihl.Web.Response.redirect_to "/ingredients"
    |> Sihl.Web.Flash.set_alert (Some "Invalid input provided")
    |> Lwt.return
;;

let delete req =
  let open Lwt.Syntax in
  let name = Sihl.Web.Router.param req "name" in
  let* ingredient = Pizza.find_ingredient name in
  match ingredient with
  | None ->
    Sihl.Web.Response.redirect_to "/ingredients"
    |> Sihl.Web.Flash.set_notice
         (Format.sprintf "Ingredient '%s' not found" name)
    |> Lwt.return
  | Some ingredient ->
    let* () = Pizza.delete_ingredient ingredient in
    Sihl.Web.Response.redirect_to "/ingredients"
    |> Sihl.Web.Flash.set_notice
         (Format.sprintf "Ingredient '%s' removed" ingredient.Pizza.name)
    |> Lwt.return
;;
