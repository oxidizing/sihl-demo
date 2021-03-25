open Tyxml

type t = Pizza.ingredient

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

let list_header = [%html {|<tr></tr>|}]
let create_link = [%html {|<a href="/ingredients/new">Create</a>|}]

let edit_link name =
  [%html
    {|<a href="|} (Format.sprintf "/ingredients/%s/edit" name) {|">Edit</a>|}]
;;

let alert_message alert =
  [%html
    {|<span class="alert">|}
      [ Html.txt (Option.value alert ~default:"") ]
      {|</span>|}]
;;

let notice_message notice =
  [%html
    {|<span class="notice">|}
      [ Html.txt (Option.value notice ~default:"") ]
      {|</span>|}]
;;

let index req csrf (ingredients : Pizza.ingredient list) =
  let open Lwt.Syntax in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let list_items =
    List.map
      ~f:(fun (ingredient : Pizza.ingredient) ->
        [%html
          {|<tr><td>|}
            [ Html.txt ingredient.Pizza.name ]
            {|</td><td>|}
            [ Html.txt (Ptime.to_rfc3339 ingredient.Pizza.created_at) ]
            {|</td><td>|}
            [ Html.txt (Ptime.to_rfc3339 ingredient.Pizza.updated_at) ]
            {|</td><td>|}
            [ delete_button ingredient csrf ]
            [ edit_link ingredient.Pizza.name ]
            {|</td></tr>|}])
      ingredients
  in
  let ingredients =
    [%html
      {|<table><tbody>|} (List.cons list_header list_items) {|</tbody></table>|}]
  in
  Lwt.return
  @@ Layout.page
       (Some user)
       [ alert_message alert; notice_message notice; create_link; ingredients ]
;;

let new' req csrf =
  let open Lwt.Syntax in
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let form =
    [%html
      {|
<form action="/ingredients" method="Post">
  <input type="hidden" name="_csrf" value="|}
        csrf
        {|">
  <span>Name</span>
  <input name="name">
  <span>Is vegan?</span>
  <input type="checkbox" name="is_vegan" value="true">
  <input type="hidden" name="is_vegan" value="false">
  <span>Price</span>
  <input name="price">
  <input type="submit" value="Create">
</form>
|}]
  in
  Lwt.return
  @@ Layout.page
       (Some user)
       [ alert_message alert; notice_message notice; form ]
;;

let show req (ingredient : Pizza.ingredient) =
  let open Lwt.Syntax in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let body =
    [%html
      {|<div>
          <span>Name:</span><span>|}
        [ Html.txt ingredient.Pizza.name ]
        {|</span>
          <span>Is vegan?</span><span>|}
        [ Html.txt (string_of_bool ingredient.Pizza.is_vegan) ]
        {|</span>
          <span>Price</span><span>|}
        [ Html.txt (string_of_int ingredient.Pizza.price) ]
        {|</span>
        </div>|}]
  in
  Lwt.return
  @@ Layout.page
       (Some user)
       [ alert_message alert; notice_message notice; body ]
;;

let edit req csrf (ingredient : Pizza.ingredient) =
  let open Lwt.Syntax in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let checkbox =
    if ingredient.Pizza.is_vegan
    then
      [%html {|<input type="checkbox" name="is_vegan" value="true" checked>|}]
    else [%html {|<input type="checkbox" name="is_vegan" value="true">|}]
  in
  let price_error =
    [%html
      {| <span>|}
        [ Html.txt (Sihl.Web.Flash.find "price" req |> Option.value ~default:"")
        ]
        {|</span>|}]
  in
  let form =
    [%html
      {|
<form action="|}
        (Format.sprintf "/ingredients/%s" ingredient.Pizza.name)
        {|" method="Post">
  <input type="hidden" name="_csrf" value="|}
        csrf
        {|">
  <input type="hidden" name="_method" value="put">
  <span>Name</span>
  <input name="name" value="|}
        ingredient.Pizza.name
        {|">
  <span>Is vegan?</span>
         |}
        [ checkbox ]
        {|
  <input type="hidden" name="is_vegan" value="false">
  <span>Price</span>|}
        [ price_error ]
        {|
  <input name="price" value="|}
        (string_of_int ingredient.Pizza.price)
        {|">
  <input type="submit" value="Update">
</form>
|}]
  in
  Lwt.return
  @@ Layout.page
       (Some user)
       [ alert_message alert; notice_message notice; form ]
;;
