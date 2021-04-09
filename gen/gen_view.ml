let template =
  {|
open Tyxml

type t = {{module}}.t

(* General *)

let%html alert_message alert =
  {|<span class="alert">\|\}
    [ Html.txt (Option.value alert ~default:"") ]
    {|</span>\|\}
;;

let%html notice_message notice =
  {|<span class="notice">\|\}
    [ Html.txt (Option.value notice ~default:"") ]
    {|</span>\|\}
;;

let%html page alert notice body =
  {|
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>{{module}}</title>
  <style>
    .alert {
        color: red;
    }

    .notice {
        color: green;
    }
  </style>
  </head>
    <body>\|\}
    [ alert_message alert ]
    [ notice_message notice ]
    body
    {|
     </body>
</html>
\|\}
;;

let%html delete_button ({{name}} : {{module}}.t) csrf =
  {|
<form action="\|\}
    (Format.sprintf "/{{name}}s/%s" {{name}}.{{module}}.id)
    {|" method="Post">
  <input type="hidden" name="_csrf" value="\|\}
    csrf
    {|">
  <input type="hidden" name="_method" value="delete">
  <input type="submit" value="Delete">
</form>
\|\}
;;

let%html create_link = {|<div><a href="/{{name}}s/new">Create</a></div>\|\}

let%html edit_link name =
  {|<a href="\|\} (Format.sprintf "/{{name}}s/%s/edit" name) {|">Edit</a>\|\}
;;

let form_comp form ({{name}} : {{module}}.t option) =
  {{form_values}}
  {{default_values}}
  [%html {| {{form}} \|\}]
;;

(* Index *)

let%html table_header = "<tr>
  <th>Id</th>
  {{table_header}}
  <th>Created at</th>
  <th>Updated at</th>
</tr>"
;;

let%html table_row csrf ({{name}} : {{module}}.t) =
  {|<tr><td><a href="\|\}
    (Format.sprintf "/{{name}}s/%s" {{name}}.{{module}}.id)
    {|">\|\}
    [ Html.txt {{name}}.{{module}}.id ]
    {|</a></td>\|\}
    {{table_rows}}
    {|<td>\|\}
    [ Html.txt (Ptime.to_rfc3339 {{name}}.{{module}}.created_at) ]
    {|</td><td>\|\}
    [ Html.txt (Ptime.to_rfc3339 {{name}}.{{module}}.updated_at) ]
    {|</td><td>\|\}
    [ delete_button {{name}} csrf ]
    [ edit_link {{name}}.{{module}}.id ]
    {|</td></tr>\|\}
;;

let%html table table_header items =
  {|<div><span>{{module}}s</span><table><tbody>\|\}
    (List.cons table_header items)
    {|</tbody></table></div>\|\}
;;

(* Views *)

let index req csrf ({{name}}s : {{module}}.t list) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let items = List.map ~f:(table_row csrf) {{name}}s in
  let table = table table_header items in
  Lwt.return @@ page alert notice [ create_link; table ]
;;

let new' req csrf (form : Rest.Form.t) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let form =
    [%html
      {|
<form action="/{{name}}s" method="Post">
  <input type="hidden" name="_csrf" value="\|\}
        csrf
        {|">
         \|\}
        (form_comp form None)
        {|
  <div>
    <input type="submit" value="Create">
  </div>
</form>
\|\}]
  in
  Lwt.return @@ page alert notice [ form ]
;;

let show req ({{name}} : {{module}}.t) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let body = [%html {{show}}] in
  Lwt.return @@ page alert notice [ body ]
;;

let edit req csrf (form : Rest.Form.t) ({{name}} : {{module}}.t) =
  let notice = Sihl.Web.Flash.find_notice req in
  let alert = Sihl.Web.Flash.find_alert req in
  let form =
    [%html
      {|
<form action="\|\}
        (Format.sprintf "/{{name}}s/%s" {{name}}.{{module}}.id)
        {|" method="Post">
  <input type="hidden" name="_csrf" value="\|\}
        csrf
        {|">
  <input type="hidden" name="_method" value="put">\|\}
        (form_comp form (Some {{name}}))
        {|<input type="submit" value="Update">
</form>
\|\}]
  in
  Lwt.return @@ page alert notice [ form ]
;;
|}
;;

let dune_template =
  {|(library
 (name view_{{name}})
 (libraries tyxml rest sihl service {{name}})
 (preprocess
  (pps tyxml-ppx)))
|}
;;

let unescape_template (t : string) : string =
  t |> CCString.replace ~sub:{|\|\}|} ~by:"|}"
;;

let table_header (schema : Gen_core.schema) : string =
  schema
  |> List.map ~f:fst
  |> List.map ~f:(Format.sprintf "<th>%s</th>")
  |> String.concat ~sep:"\n"
;;

let stringify name module_ (field_name, type_) =
  let open Gen_core in
  match type_ with
  | Float ->
    Format.sprintf
      "[ Html.txt (string_of_float %s.%s.%s) ]"
      name
      module_
      field_name
  | Int ->
    Format.sprintf
      "[ Html.txt (string_of_int %s.%s.%s) ]"
      name
      module_
      field_name
  | Bool ->
    Format.sprintf
      "[ Html.txt (string_of_bool %s.%s.%s) ]"
      name
      module_
      field_name
  | String -> Format.sprintf "[ Html.txt %s.%s.%s ]" name module_ field_name
  | Datetime ->
    Format.sprintf
      "[ Html.txt (Ptime.to_rfc3339 %s.%s.%s) ]"
      name
      module_
      field_name
;;

let table_rows name module_ (schema : Gen_core.schema) =
  schema
  |> List.map ~f:(fun field ->
         Format.sprintf "\"<td>\"%s\"</td>\"" (stringify name module_ field))
  |> String.concat ~sep:"\n"
;;

let form_values schema =
  schema
  |> List.map ~f:fst
  |> List.map ~f:(fun name ->
         Format.sprintf
           "let old_%s, %s_error = Rest.Form.find \"%s\" form in"
           name
           name
           name)
  |> String.concat ~sep:"\n"
;;

let default_value type_ =
  let open Gen_core in
  match type_ with
  | Float -> "0.0"
  | Int -> "0"
  | Bool -> "false"
  | String -> "\"\""
  | Datetime -> "(Ptime_clock.now ())"
;;

let default_values name module_ schema =
  schema
  |> List.map ~f:(fun (field_name, field_type) ->
         Format.sprintf
           {|
  let current_%s =
    %s
    |> Option.map (fun (%s : %s.t) -> %s.%s.%s)
    |> Option.value ~default:%s
  in
|}
           field_name
           name
           name
           module_
           name
           module_
           field_name
           (default_value field_type))
  |> String.concat ~sep:"\n"
;;

let form_input (field_name, field_type) =
  let open Gen_core in
  match field_type with
  | Float ->
    Format.sprintf
      {|<input name="%s" value="\|\}
        (Option.value ~default:current_%s old_%s)
        {|">|}
      field_name
      field_name
      field_name
  | Int ->
    Format.sprintf
      {|<input name="%s" value="\|\}
        (Option.value ~default:(string_of_int current_%s) old_%s)
        {|">|}
      field_name
      field_name
      field_name
  | Bool ->
    (* TODO [jerben] fix checkbox *)
    Format.sprintf
      {|<input name="%s" value="\|\}
        (Option.value ~default:(string_of_bool current_%s) old_%s)
        {|">|}
      field_name
      field_name
      field_name
  | String ->
    Format.sprintf
      {|<input name="%s" value="\|\}
        (Option.value ~default:current_%s old_%s)
        {|">|}
      field_name
      field_name
      field_name
  | Datetime ->
    Format.sprintf
      {|<input type="date" name="%s" value="\|\}
        (Option.value ~default:(Ptime.to_rfc3339 current_%s) old_%s)
        {|">|}
      field_name
      field_name
      field_name
;;

let alert (field_name, _) =
  Format.sprintf
    {|<p class="alert">\|\}
      [ Html.txt (Option.value ~default:"" %s_error) ]
  {|</p>|}
    field_name
;;

let form_elements schema =
  schema
  |> List.map ~f:(fun field ->
         Format.sprintf
           {|
    <div>
      <label>%s</label>
      %s
    </div>
    %s
|}
           (fst field)
           (form_input field)
           (alert field))
  |> String.concat ~sep:"\n"
  |> unescape_template
;;

let show name module_ (schema : Gen_core.schema) =
  schema
  |> List.map ~f:(fun field ->
         Format.sprintf
           {|"<div><span>%s: </span><span>" %s "</span></div>"|}
           name
           (stringify name module_ field))
  |> String.concat ~sep:"\n"
  |> fun fields ->
  Format.sprintf
    "\"<div>\"%s [ edit_link %s.%s.id ]\"</div>\""
    fields
    name
    module_
;;

let create_params name (schema : Gen_core.schema) =
  let module_ = CCString.capitalize_ascii name in
  [ "module", module_
  ; "name", name
  ; "table_header", table_header schema
  ; "table_rows", table_rows name module_ schema
  ; "form_values", form_values schema
  ; "default_values", default_values name module_ schema
  ; "form", form_elements schema
  ; "show", show name module_ schema
  ]
;;

let generate (name : string) (schema : Gen_core.schema) =
  if String.contains name ':'
  then failwith "Invalid service name provided, it can not contain ':'"
  else (
    let dune_file =
      Gen_core.
        { name = "dune"; template = dune_template; params = [ "name", name ] }
    in
    let file =
      Gen_core.
        { name = Format.sprintf "view_%s.ml" name
        ; template = unescape_template template
        ; params = create_params name schema
        }
    in
    Gen_core.write_in_view name [ dune_file; file ])
;;
