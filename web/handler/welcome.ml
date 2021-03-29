let index req =
  let open Lwt.Syntax in
  let* user = Service.User.Web.user_from_session req in
  Lwt.return @@ Sihl.Web.Response.of_html (View.Welcome.page user)
;;
