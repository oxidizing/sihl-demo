open Tyxml

let create_form csrf ingredients =
  let ingredients_options =
    Stdlib.List.map
      (fun (ingredient : Pizza.ingredient) ->
        [%html
          {|<option value="|}
            ingredient.Pizza.name
            {|">|}
            (Html.txt ingredient.Pizza.name)
            {|</option>|}])
      ingredients
  in
  let%html form =
    {|
<form action="/pizzas" method="Post">
  <input type="hidden" name="_csrf" value="|}
      csrf
      {|">
  <input name="name"><br />
  <select name="ingredients" multiple>
      |}
      ingredients_options
      {|
    </select>
    <input type="submit" value="Create">
</form>
|}
  in
  form
;;

let%html delete_button (pizza : Pizza.t) csrf =
  {|
<form action="|}
    (Format.sprintf "/pizzas/%s/delete" pizza.Pizza.name)
    {|" method="Post">
  <input type="hidden" name="_csrf" value="|}
    csrf
    {|">
  <input type="submit" value="Delete">
</form>
|}
;;

let index
    user
    ~alert
    ~notice
    csrf
    (pizzas : Pizza.t list)
    (ingredients : Pizza.ingredient list)
  =
  let list_items =
    Stdlib.List.map
      (fun (pizza : Pizza.t) ->
        let ingredients_list =
          Stdlib.List.map
            (fun (ingredient : string) ->
              [%html {|<li>|} [ Html.txt ingredient ] {|</li>|}])
            pizza.Pizza.ingredients
        in
        let ingredients = [%html {|<ul>|} ingredients_list {|</ul>|}] in
        [%html
          {|<tr><td><a href="|}
            (Format.sprintf "/pizzas/%s" pizza.Pizza.name)
            {|">|}
            [ Html.txt pizza.Pizza.name ]
            {|</a></td><td>|}
            [ ingredients ]
            {|</td><td>|}
            [ Html.txt (Ptime.to_rfc3339 pizza.Pizza.created_at) ]
            {|</td><td>|}
            [ Html.txt (Ptime.to_rfc3339 pizza.Pizza.updated_at) ]
            {|</td><td>|}
            [ delete_button pizza csrf ]
            {|</td></tr>|}])
      pizzas
  in
  let alert_message =
    [%html {|<span>|} [ Html.txt (Option.value alert ~default:"") ] {|</span>|}]
  in
  let notice_message =
    [%html
      {|<span>|} [ Html.txt (Option.value notice ~default:"") ] {|</span>|}]
  in
  let pizzas = [%html {|<table><tbody>|} list_items {|</tbody></table>|}] in
  Layout.page
    (Some user)
    [ alert_message; notice_message; create_form csrf ingredients; pizzas ]
;;

let show user ~alert ~notice (pizza : Pizza.t) =
  let item =
    [%html
      {|<div>|} {|<h1>|} [ Html.txt pizza.Pizza.name ] {|</h1>|} {|</div>|}]
  in
  let ingredients_list =
    List.map
      ~f:(fun (ingredient : string) ->
        [%html {|<li>|} [ Html.txt ingredient ] {|</li>|}])
      pizza.Pizza.ingredients
  in
  let ingredients =
    [%html
      {|<div><h2>|}
        "Ingredients:"
        {|</h2>|}
        {|<ul>|}
        ingredients_list
        {|</ul></div>|}]
  in
  let back_button =
    [%html {|<div><br /><a href="/pizzas">|} "back" {|</a></div>|}]
  in
  let alert_message =
    [%html {|<span>|} [ Html.txt (Option.value alert ~default:"") ] {|</span>|}]
  in
  let notice_message =
    [%html
      {|<span>|} [ Html.txt (Option.value notice ~default:"") ] {|</span>|}]
  in
  Layout.page
    (Some user)
    [ alert_message; notice_message; item; ingredients; back_button ]
;;
