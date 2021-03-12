let index req =
  let user = Sihl.Web.User.find_opt req in
  Lwt.return @@ Sihl.Web.Response.of_html (View.Welcome.page user)
;;
