let login_index req =
  match Sihl.Web.User.find_opt req with
  | Some _ -> Sihl.Web.Response.redirect_to "/ingredients" |> Lwt.return
  | None ->
    let csrf = Sihl.Web.Csrf.find req in
    let alert = Sihl.Web.Flash.find_alert req in
    Lwt.return @@ Sihl.Web.Response.of_html (View.Auth.login ~alert csrf)
;;

let login_create req =
  let open Lwt.Syntax in
  Logs.err (fun m -> m "%a" Sihl.Web.Form.pp (Sihl.Web.Form.find_all req));
  match Sihl.Web.Form.find_all req with
  | [ ("email", [ email ]); ("password", [ password ]) ] ->
    let* user = Service.User.login ~email ~password in
    (match user with
    | Ok user ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Session.set ("user_id", Some user.Sihl.Contract.User.id)
      |> Lwt.return
    | Error _ ->
      Sihl.Web.Response.redirect_to "/login"
      |> Sihl.Web.Flash.set_alert (Some "Invalid email or password provided")
      |> Lwt.return)
  | _ ->
    Sihl.Web.Response.redirect_to "/login"
    |> Sihl.Web.Flash.set_alert (Some "Invalid input provided")
    |> Lwt.return
;;

let registration_index req =
  match Sihl.Web.User.find_opt req with
  | Some _ -> Sihl.Web.Response.redirect_to "/ingredients" |> Lwt.return
  | None ->
    let csrf = Sihl.Web.Csrf.find req in
    let alert = Sihl.Web.Flash.find_alert req in
    Lwt.return @@ Sihl.Web.Response.of_html (View.Auth.registration ~alert csrf)
;;

let registration_create req =
  let open Lwt.Syntax in
  match Sihl.Web.Form.find_all req with
  | [ ("email", [ email ])
    ; ("password", [ password ])
    ; ("password_confirmation", [ password_confirmation ])
    ] ->
    let* user = Service.User.register_user ~email ~password ~password_confirmation () in
    (match user with
    | Ok user ->
      Sihl.Web.Response.redirect_to "/ingredients"
      |> Sihl.Web.Session.set ("user_id", Some user.Sihl.Contract.User.id)
      |> Lwt.return
    | Error _ ->
      Sihl.Web.Response.redirect_to "/registration"
      |> Sihl.Web.Flash.set_alert (Some "Invalid email or password provided")
      |> Lwt.return)
  | _ ->
    Sihl.Web.Response.redirect_to "/registration"
    |> Sihl.Web.Flash.set_alert (Some "Invalid input provided")
    |> Lwt.return
;;
