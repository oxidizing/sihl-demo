open Tyxml

type t = Pizza.ingredient

let skip_index_fetch = false

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

let list_header =
  [%html
    {|<tr><th>Name</th><th>Price</th><th>Vegan</th><th>Update at</th><th>Created at</th></tr>|}]
;;

let create_link = [%html {|<div><a href="/ingredients/new">Create</a></div>|}]

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

let index
    req
    csrf
    (result : Pizza.ingredient list * int)
    (_ : Sihl.Web.Rest.query)
  =
  let open Lwt.Syntax in
  let ingredients, _ = result in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let list_items =
    List.map
      ~f:(fun (ingredient : Pizza.ingredient) ->
        [%html
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
            {|</td></tr>|}])
      ingredients
  in
  let ingredients =
    [%html
      {|<div><span>Ingredients</span><table><tbody>|}
        (List.cons list_header list_items)
        {|</tbody></table></div>|}]
  in
  Lwt.return
  @@ Layout.page
       (Some user)
       [ alert_message alert; notice_message notice; create_link; ingredients ]
;;

let new' req csrf (form : Sihl.Web.Rest.form) =
  let open Lwt.Syntax in
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let name_value, name_error = Sihl.Web.Rest.find_form "name" form in
  let vegan_value, _ = Sihl.Web.Rest.find_form "is_vegan" form in
  let price_value, price_error = Sihl.Web.Rest.find_form "price" form in
  let checkbox =
    if Option.bind vegan_value bool_of_string_opt |> Option.value ~default:false
    then
      [%html {|<input type="checkbox" name="is_vegan" value="true" checked>|}]
    else [%html {|<input type="checkbox" name="is_vegan" value="true">|}]
  in
  let form =
    [%html
      {|
<form action="/ingredients" method="Post">
  <input type="hidden" name="_csrf" value="|}
        csrf
        {|">
  <div>
    <span>Name</span>
    <input name="name" value="|}
        (Option.value ~default:"" name_value)
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
        (Option.value ~default:"" price_value)
        {|">
  </div>
  <p class="alert">|}
        [ Html.txt (Option.value ~default:"" price_error) ]
        {|</p>
  <div>
    <input type="submit" value="Create">
  </div>
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
  Lwt.return
  @@ Layout.page
       (Some user)
       [ alert_message alert; notice_message notice; body ]
;;

let edit req csrf (form : Sihl.Web.Rest.form) (ingredient : Pizza.ingredient) =
  let open Lwt.Syntax in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let name, name_error = Sihl.Web.Rest.find_form "name" form in
  let vegan, _ = Sihl.Web.Rest.find_form "is_vegan" form in
  let price_value, price_error = Sihl.Web.Rest.find_form "price" form in
  let checkbox =
    if ingredient.Pizza.is_vegan
       || Option.equal String.equal vegan (Some "true")
    then
      [%html {|<input type="checkbox" name="is_vegan" value="true" checked>|}]
    else [%html {|<input type="checkbox" name="is_vegan" value="true">|}]
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
  <div>
    <span>Name</span>
    <input name="name" value="|}
        (Option.value ~default:ingredient.Pizza.name name)
        {|">
  </div>
  <p class="alert">|}
        [ Html.txt (Option.value ~default:"" name_error) ]
        {|</p>
  <div>
    <label>Is it vegan?</label>
         |}
        [ checkbox ]
        {|
    <input type="hidden" name="is_vegan" value="false">
  </div>
  <div>
    <label>Price</label>
    <input name="price" value="|}
        (Option.value
           ~default:(string_of_int ingredient.Pizza.price)
           price_value)
        {|">
  </div>
  <p class="alert">|}
        [ Html.txt (Option.value ~default:"" price_error) ]
        {|</p>
  <input type="submit" value="Update">
</form>
|}]
  in
  Lwt.return
  @@ Layout.page
       (Some user)
       [ alert_message alert; notice_message notice; form ]
;;
