(* Put custom Opium middlewares here *)

(* [middleware login_path] returns a middleware that redirects to [login_path]
   if no user is present. Use it to enforce authentication on routers. *)
let middleware login_path =
  let filter handler req =
    let open Lwt.Syntax in
    let* user = Service.User.Web.user_from_session req in
    match user with
    | None -> Lwt.return @@ Sihl.Web.Response.redirect_to login_path
    | Some _ -> handler req
  in
  Rock.Middleware.create ~name:"authentication" ~filter
;;
