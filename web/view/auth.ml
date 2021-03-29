open Tyxml

let%html login_form csrf =
  {|
<form action="/login" method="Post">
  <input type="hidden" name="_csrf" value="|}
    csrf
    {|">
  <input name="email">
  <input name="password">
  <input type="submit" value="Login">
</form>
|}
;;

let login ~alert csrf =
  let alert_message =
    [%html {|<span>|} [ Html.txt (Option.value alert ~default:"") ] {|</span>|}]
  in
  Layout.page None [ alert_message; login_form csrf ]
;;

let%html registration_form csrf =
  {|
<form action="/registration" method="Post">
  <input type="hidden" name="_csrf" value="|}
    csrf
    {|">
  <input name="email">
  <input name="password">
  <input name="password_confirmation">
  <input type="submit" value="Register">
</form>
|}
;;

let registration ~alert csrf =
  let alert_message =
    [%html {|<span>|} [ Html.txt (Option.value alert ~default:"") ] {|</span>|}]
  in
  Layout.page None [ alert_message; registration_form csrf ]
;;
