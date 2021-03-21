open Tyxml

let%html create_form csrf =
  {|
<form action="/ingredients" method="Post">
  <input type="hidden" name="_csrf" value="|}
    csrf
    {|">
  <input name="name">
  <input type="submit" value="Create">
</form>
|}
;;

let%html delete_button (ingredient : Pizza.ingredient) csrf =
  {|
<form action="|}
    (Format.sprintf "/ingredients/%s/delete" ingredient.Pizza.name)
    {|" method="Post">
  <input type="hidden" name="_csrf" value="|}
    csrf
    {|">
  <input type="submit" value="Delete">
</form>
|}
;;

let index user ~alert ~notice csrf (ingredients : Pizza.ingredient list) =
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
            {|</td></tr>|}])
      ingredients
  in
  let alert_message =
    [%html {|<span>|} [ Html.txt (Option.value alert ~default:"") ] {|</span>|}]
  in
  let notice_message =
    [%html
      {|<span>|} [ Html.txt (Option.value notice ~default:"") ] {|</span>|}]
  in
  let list_header = [%html {|<tr></tr>|}] in
  let ingredients =
    [%html
      {|<table><tbody>|} (List.cons list_header list_items) {|</tbody></table>|}]
  in
  Layout.page
    (Some user)
    [ alert_message; notice_message; create_form csrf; ingredients ]
;;
