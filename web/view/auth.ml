open Tyxml

let%html login_form csrf =
  {|
<form action="/login" method="Post">
  <input type="hidden" name="_csrf" value="|}
    csrf
    {|">
  <div>
    <label>Email</label>
    <input name="email">
  </div>
  <div>
    <label>Password</label>
    <input name="password">
  </div>
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
  <div>
    <label>Email</label>
    <input name="email">
  </div>
  <div>
    <label>Password</label>
    <input name="password">
  </div>
  <div>
    <label>Confirm pasword</label>
    <input name="password_confirmation">
  </div>
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
