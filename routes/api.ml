(* All the JSON HTTP entry points are listed here.

   Don't put actual logic here to keep it declarative and easy to read. The
   overall scope of the web app should be clear after scanning the routes. *)

let middlewares = []
let router = Sihl.Web.choose ~middlewares ~scope:"/api" []
