open Tyxml

type t = Pizza.ingredient

(* General *)

let%html alert_message alert =
  {|<span class="alert">|}
    [ Html.txt (Option.value alert ~default:"") ]
    {|</span>|}
;;

let%html notice_message notice =
  {|<span class="notice">|}
    [ Html.txt (Option.value notice ~default:"") ]
    {|</span>|}
;;

let%html page alert notice body =
  {|
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Pizza</title>
  <style>
    .alert {
        color: red;
    }

    .notice {
        color: green;
    }
  </style>
  </head>
    <body>|}
    [ alert_message alert ]
    [ notice_message notice ]
    body
    {|
     </body>
</html>
|}
;;

let%html delete_button (ingredient : Pizza.ingredient) csrf =
  {|
<form action="|}
    (Format.sprintf "/ingredients/%s" ingredient.Pizza.name)
    {|" method="Post">
  <input type="hidden" name="_csrf" value="|}
    csrf
    {|">
  <input type="hidden" name="_method" value="delete">
  <input type="submit" value="Delete">
</form>
|}
;;

let%html create_link = {|<div><a href="/ingredients/new">Create</a></div>|}

let%html edit_link name =
  {|<a href="|} (Format.sprintf "/ingredients/%s/edit" name) {|">Edit</a>|}
;;

let form_comp form (ingredient : Pizza.ingredient option) =
  (* The old_ values are the values from a previous form submission *)
  let old_name, name_error = Rest.Form.find "name" form in
  let old_vegan, _ = Rest.Form.find "is_vegan" form in
  let old_price, price_error = Rest.Form.find "price" form in
  let current_name =
    ingredient
    |> Option.map (fun (ingredient : Pizza.ingredient) -> ingredient.Pizza.name)
    |> Option.value ~default:""
  in
  let current_vegan =
    ingredient
    |> Option.map (fun (ingredient : Pizza.ingredient) ->
           ingredient.Pizza.is_vegan)
    |> Option.value ~default:false
  in
  let current_price =
    ingredient
    |> Option.map (fun (ingredient : Pizza.ingredient) ->
           ingredient.Pizza.price)
    |> Option.value ~default:0
  in
  let checkbox =
    if current_vegan || Option.equal String.equal old_vegan (Some "true")
    then
      [%html {|<input type="checkbox" name="is_vegan" value="true" checked>|}]
    else [%html {|<input type="checkbox" name="is_vegan" value="true">|}]
  in
  [%html
    {|
  <div>
    <span>Name</span>
    <input name="name" value="|}
      (Option.value ~default:current_name old_name)
      {|">
  </div>
  <p class="alert">|}
      [ Html.txt (Option.value ~default:"" name_error) ]
      {|</p>
  <div>
    <label>Is it vegan?</label>|}
      [ checkbox ]
      {|
    <input type="hidden" name="is_vegan" value="false">
  </div>
  <div>
    <label>Price</label>
    <input name="price" value="|}
      (Option.value ~default:(string_of_int current_price) old_price)
      {|">
  </div>
  <p class="alert">|}
      [ Html.txt (Option.value ~default:"" price_error) ]
      {|</p>
  |}]
;;

(* Index *)

let%html table_header =
  "<tr><th>Name</th><th>Price</th><th>Vegan</th><th>Update at</th><th>Created \
   at</th></tr>"
;;

let%html table_row csrf (ingredient : Pizza.ingredient) =
  {|<tr><td><a href="|}
    (Format.sprintf "/ingredients/%s" ingredient.Pizza.name)
    {|">|}
    [ Html.txt ingredient.Pizza.name ]
    {|</a></td><td>|}
    [ Html.txt (string_of_int ingredient.Pizza.price) ]
    {|</td><td>|}
    [ Html.txt (string_of_bool ingredient.Pizza.is_vegan) ]
    {|</td><td>|}
    [ Html.txt (Ptime.to_rfc3339 ingredient.Pizza.created_at) ]
    {|</td><td>|}
    [ Html.txt (Ptime.to_rfc3339 ingredient.Pizza.updated_at) ]
    {|</td><td>|}
    [ delete_button ingredient csrf ]
    [ edit_link ingredient.Pizza.name ]
    {|</td></tr>|}
;;

let%html table table_header items =
  {|<div><span>Ingredients</span><table><tbody>|}
    (List.cons table_header items)
    {|</tbody></table></div>|}
;;

(* Views *)

let index req csrf (ingredients : Pizza.ingredient list) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let items = List.map ~f:(table_row csrf) ingredients in
  let table = table table_header items in
  Lwt.return @@ page alert notice [ create_link; table ]
;;

let new' req csrf (form : Rest.Form.t) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let form =
    [%html
      {|
<form action="/ingredients" method="Post">
  <input type="hidden" name="_csrf" value="|}
        csrf
        {|">
         |}
        (form_comp form None)
        {|
  <div>
    <input type="submit" value="Create">
  </div>
</form>
|}]
  in
  Lwt.return @@ page alert notice [ form ]
;;

let show req (ingredient : Pizza.ingredient) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let body =
    [%html
      {|<div><div>
          <span>Name: </span><span>|}
        [ Html.txt ingredient.Pizza.name ]
        {|</span></div>
        <div><span>Vegan: </span><span>|}
        [ Html.txt (string_of_bool ingredient.Pizza.is_vegan) ]
        {|</span></div>
         <div><span>Price: </span><span>|}
        [ Html.txt (string_of_int ingredient.Pizza.price) ]
        {|</span></div>|}
        [ edit_link ingredient.Pizza.name ]
        {|</div>|}]
  in
  Lwt.return @@ page alert notice [ body ]
;;

let edit req csrf (form : Rest.Form.t) (ingredient : Pizza.ingredient) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let form =
    [%html
      {|
<form action="|}
        (Format.sprintf "/ingredients/%s" ingredient.Pizza.name)
        {|" method="Post">
  <input type="hidden" name="_csrf" value="|}
        csrf
        {|">
  <input type="hidden" name="_method" value="put">|}
        (form_comp form (Some ingredient))
        {|<input type="submit" value="Update">
</form>
|}]
  in
  Lwt.return @@ page alert notice [ form ]
;;
