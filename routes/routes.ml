(* All the HTML HTTP entry points are listed in this file.

   Don't put actual logic here and keep the routes declarative and easy to read.
   The overall scope of the web app should be clear after scanning the routes. *)

let global_middlewares =
  [ Sihl.Web.Middleware.id ()
  ; Sihl.Web.Middleware.error ()
  ; Sihl.Web.Middleware.static_file ()
  ]
;;

let site_middlewares =
  [ Opium.Middleware.content_length
  ; Opium.Middleware.etag
  ; Sihl.Web.Middleware.csrf ()
  ; Sihl.Web.Middleware.flash ()
  ]
;;

let site_public =
  Sihl.Web.combine
    ~middlewares:site_middlewares
    "/"
    Sihl.Web.
      [ get "/" Handler.Welcome.index
      ; get "/login" Handler.Auth.login_index
      ; post "/login" Handler.Auth.login_create
      ; get "/logout" Handler.Auth.login_delete
      ; get "/registration" Handler.Auth.registration_index
      ; post "/registration" Handler.Auth.registration_create
      ]
;;

let private_middlewares =
  List.concat [ site_middlewares; [ Middleware.Authn.middleware "/login" ] ]
;;

let site_private_ =
  Sihl.Web.combine
    ~middlewares:private_middlewares
    "/"
    Sihl.Web.
      [ get "/ingredients" Handler.Ingredients.index
      ; post "/ingredients" Handler.Ingredients.create
      ; post "/ingredients/:name/delete" Handler.Ingredients.delete
      ; get "/pizzas" Handler.Pizzas.index
      ; post "/pizzas" Handler.Pizzas.index
      ; delete "/pizzas/:name" Handler.Pizzas.delete
      ]
;;

let api = Sihl.Web.combine "/api" []
let router = Sihl.Web.combine "/" [ site_public; site_private_; api ]
