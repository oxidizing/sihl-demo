let template =
  {|
open Tyxml

type t = {{module}}.t

let%html delete_button ({{name}} : {{module}}.name) csrf =
  \{\|
<form action="\|\}
    (Format.sprintf "/{{name}}s/%s" {{name}}.{{module}}.id)
    \{\|" method="Post">
  <input type="hidden" name="_csrf" value="\|\}
    csrf
    \{\|">
  <input type="hidden" name="_method" value="delete">
  <input type="submit" value="Delete">
</form>
\|\}
;;

let list_header =
  [%html
    \{\|{{table_header}}\|\}]
;;

let create_link = [%html \{\|<div><a href="/{{name}s/new">Create</a></div>\|\}]

let edit_link id =
  [%html
    \{\|<a href="\|\} (Format.sprintf "/{{name}}/%s/edit" id) \{\|">Edit</a>\|\}]
;;

let alert_message alert =
  [%html
    \{\|<span class="alert">\|\}
      [ Html.txt (Option.value alert ~default:"") ]
      \{\|</span>\|\}]
;;

let notice_message notice =
  [%html
    \{\|<span class="notice">\|\}
      [ Html.txt (Option.value notice ~default:"") ]
      \{\|</span>\|\}]
;;

let index req csrf ({{name}}s : {{module}}.t list) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let list_items =
    List.map
      ~f:(fun ({{name}} : {{module}}.t) ->
        [%html
         "<tr><td><a href=\""
         (Format.sprintf "/{{name}}s/%s" {{name}}.{{module}}.id)
         \{\|">\|\}
         [ Html.txt {{name}}.{{module}}.id ]
         \{\|</a></td>\|\}
         {{table_row}}
         "<td>"
         [ Html.txt (Ptime.to_rfc3339 {{name}}.{{module}}.created_at) ]
         "</td><td>"
         [ Html.txt (Ptime.to_rfc3339 {{name}}.{{module}}.updated_at) ]
         "</td><td>"
         [ delete_button {{name}} csrf ]
         [ edit_link {{name}}.{{module}}.id ]
         "</td></tr>"])
  in
  let {{name}}s =
    [%html
      \{\|<div><span>{{module}}s</span><table><tbody>\|\}
        (List.cons list_header list_items)
        \{\|</tbody></table></div>\|\}]
  in
  Lwt.return
  @@ Layout.page
       None
       [ alert_message alert; notice_message notice; create_link; {{name}}s ]
;;

let new' req csrf (form : Rest.Form.t) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let name_value, name_error = Rest.Form.find "name" form in
  let vegan_value, _ = Rest.Form.find "is_vegan" form in
  let price_value, price_error = Rest.Form.find "price" form in
  let form = [%html \{\|
{{form}}
\|\}] in
  Lwt.return
  @@ Layout.page
       None
       [ alert_message alert; notice_message notice; form ]
;;

let show req ({{name}} : {{module}}.t) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let body = [%html \{\|
{{show}}
\|\}] in
  Lwt.return
  @@ Layout.page
       None
       [ alert_message alert; notice_message notice; body ]
;;

let edit req csrf (form : Rest.Form.t) ({{name}} : {{module}}.t) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  {{form_values}}
  let form = [%html \{\|
{{form}}
\|\}] in
  Lwt.return
  @@ Layout.page
       None
       [ alert_message alert; notice_message notice; form ]
;;

|}
;;

let unescape_template (t : string) : string =
  t
  |> CCString.replace ~sub:{|\{\||} ~by:"{|"
  |> CCString.replace ~sub:{|\|\}|} ~by:"|}"
;;

let table_header (schema : Gen_core.schema) : string =
  schema
  |> List.map ~f:fst
  |> List.map ~f:(Format.sprintf "<th>%s</th>")
  |> String.concat ~sep:""
  |> Format.sprintf "<tr>%s</tr>"
;;

let table_cell name module_ (field_name, type_) =
  let open Gen_core in
  match type_ with
  | Float ->
    Format.sprintf
      {|"<td>"[ Html.txt (string_of_float %s.%s.%s) ]"</td>"|}
      name
      module_
      field_name
  | Int ->
    Format.sprintf
      {|"<td>"[ Html.txt (string_of_int %s.%s.%s) ]"</td>"|}
      name
      module_
      field_name
  | Bool ->
    Format.sprintf
      {|"<td>"[ Html.txt (string_of_bool %s.%s.%s) ]"</td>"|}
      name
      module_
      field_name
  | String ->
    Format.sprintf
      {|"<td>"[ Html.txt %s.%s.%s ]"</td>"|}
      name
      module_
      field_name
  | Datetime ->
    Format.sprintf
      {|"<td>"[ Html.txt %s.%s.%s ]"</td>"|}
      name
      module_
      field_name
;;

let table_row name module_ (schema : Gen_core.schema) =
  schema
  |> List.map ~f:(table_cell name module_)
  |> String.concat ~sep:"\n"
  |> Format.sprintf "<tr>%s</tr>"
;;

let form_values _ = ""
let form _ = {|<form></form>|}
let show _ = {|<form></form>|}

let create_params name (schema : Gen_core.schema) =
  let module_ = CCString.capitalize_ascii name in
  [ "module", module_
  ; "name", name
  ; "table_header", table_header schema
  ; "table_row", table_row name module_ schema
  ; "form_values", form_values schema
  ; "form", form schema
  ; "show", show schema
  ]
;;

let generate (name : string) (schema : Gen_core.schema) =
  if String.contains name ':'
  then failwith "Invalid service name provided, it can not contain ':'"
  else (
    let file =
      Gen_core.
        { name = Format.sprintf "%s.ml" name
        ; template = unescape_template template
        ; params = create_params name schema
        }
    in
    Gen_core.write_in_view file)
;;
