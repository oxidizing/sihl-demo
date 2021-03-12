(* Put custom Opium middlewares here *)

(* [middleware login_path] returns a middleware that redirects to [login_path]
   if no user is present. Use it to enforce authentication on routers. *)
let middleware login_path =
  let filter handler req =
    match Sihl.Web.User.find_opt req with
    | None -> Lwt.return @@ Sihl.Web.Response.redirect_to login_path
    | Some _ -> handler req
  in
  Rock.Middleware.create ~name:"authentication" ~filter
;;
