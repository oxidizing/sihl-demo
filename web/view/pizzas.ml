open Tyxml

let%html create_form csrf =
  {|
<form action="/pizzas" method="Post">
  <input type="hidden" name="_csrf" value="|}
    csrf
    {|">
  <input name="name">
  <input type="submit" value="Create">
</form>
|}
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

let index user ~alert ~notice csrf (pizzas : Pizza.t list) =
  let list_items =
    List.map
      ~f:(fun (pizza : Pizza.t) ->
        let ingredients_list =
          List.map
            ~f:(fun (ingredient : string) ->
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
  let list_header = [%html {|<tr></tr>|}] in
  let pizzas =
    [%html
      {|<table><tbody>|} (List.cons list_header list_items) {|</tbody></table>|}]
  in
  Layout.page
    (Some user)
    [ alert_message; notice_message; create_form csrf; pizzas ]
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
  let ingredients = [%html {|<ul>|} ingredients_list {|</ul>|}] in
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
