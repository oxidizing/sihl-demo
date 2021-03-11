let index req =
  let open Lwt.Syntax in
  let csrf = Sihl.Web.Csrf.find req in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* ingredients = Pizza.find_ingredients () in
  Lwt.return
  @@ Sihl.Web.Response.of_html (View.Ingredients.index ~alert ~notice csrf ingredients)
;;

let create req =
  let open Lwt.Syntax in
  match Sihl.Web.Form.find "name" req with
  | None ->
    Sihl.Web.Response.redirect_to "/ingredients"
    |> Sihl.Web.Flash.set_alert (Some "Invalid input provided")
    |> Lwt.return
  | Some name ->
    let* ingredient = Pizza.create_ingredient name in
    (match ingredient with
    | Ok ingredient ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_notice
           (Some (Format.sprintf "Ingredient '%s' added" ingredient.Pizza.name))
      |> Lwt.return
    | Error msg ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Flash.set_alert (Some msg)
      |> Lwt.return)
;;

let delete _ = failwith "todo"
