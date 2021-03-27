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

let create req =
  let open Lwt.Syntax in
  let* name = Sihl.Web.Request.urlencoded "name" req in
  match name with
  | None ->
    Sihl.Web.Response.redirect_to "/ingredients"
    |> Sihl.Web.Flash.set_alert "Invalid input provided"
    |> Lwt.return
  | Some name ->
    let* ingredient = Pizza.create_ingredient name in
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
