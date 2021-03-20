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
  let open Tyxml in
  let csrf = Sihl.Web.Csrf.find req |> Option.get in
  let form =
    [%html
      {|
<form action="/ingredients" method="Post">
  <input type="hidden" name="_csrf" value="|}
        csrf
        {|">
  <input name="name">
  <input type="submit" value="Create">
</form>
|}]
  in
  Lwt.return
  @@ Sihl.Web.Response.of_plain_text
       (Format.asprintf "%a" (Html.pp_elt ()) form)
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
  let open Tyxml in
  let name = Sihl.Web.Router.param req "name" in
  let* ingredient = Pizza.find_ingredient name |> Lwt.map Option.get in
  let html =
    [%html
      {|<div><span>Name:</span><span>|}
        [ Html.txt ingredient.Pizza.name ]
        {|</span></div>|}]
  in
  Lwt.return
  @@ Sihl.Web.Response.of_plain_text
       (Format.asprintf "%a" (Html.pp_elt ()) html)
;;

let edit req =
  let open Tyxml in
  let name = Sihl.Web.Router.param req "name" in
  let csrf = Sihl.Web.Csrf.find req |> Option.get in
  let form =
    [%html
      {|
<form action="|}
        (Format.sprintf "/ingredients/%s" name)
        {|" method="Post">
  <input type="hidden" name="_csrf" value="|}
        csrf
        {|">
  <input type="hidden" name="_method" value="Put">
  <input name="name">
  <input type="submit" value="Update">
</form>
|}]
  in
  Lwt.return
  @@ Sihl.Web.Response.of_plain_text
       (Format.asprintf "%a" (Html.pp_elt ()) form)
;;

let update _ = failwith "todo"

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
