(* All the HTML HTTP entry points are listed in this file.

   Don't put actual logic here and keep the routes declarative and easy to read.
   The overall scope of the web app should be clear after scanning the routes. *)

let middlewares =
  [ Opium.Middleware.content_length
  ; Opium.Middleware.etag
  ; Sihl.Web.Middleware.csrf ()
  ; Sihl.Web.Middleware.flash ()
  ]
;;

let router_private =
  Sihl.Web.choose
    ~middlewares:
      (List.concat [ middlewares; [ Middleware.Authn.middleware "/login" ] ])
    ~scope:"/"
    Sihl.Web.
      [ get "/ingredients" Handler.Ingredients.index
      ; post "/ingredients" Handler.Ingredients.create
      ; post "/ingredients/:name/delete" Handler.Ingredients.delete
      ; get "/pizzas" Handler.Pizzas.index
      ; post "/pizzas" Handler.Pizzas.index
      ; get "/pizzas/:name" Handler.Pizzas.show
      ; post "/pizzas/:name/delete" Handler.Pizzas.delete
      ]
;;

let router_public =
  Sihl.Web.choose
    ~middlewares
    ~scope:"/"
    Sihl.Web.
      [ get "/" Handler.Welcome.index
      ; get "/login" Handler.Auth.login_index
      ; post "/login" Handler.Auth.login_create
      ; get "/logout" Handler.Auth.login_delete
      ; get "/registration" Handler.Auth.registration_index
      ; post "/registration" Handler.Auth.registration_create
      ]
;;

let router_admin_queue =
  Sihl.Web.choose
    ~middlewares:[ Middleware.Authn.middleware "/login" ]
    [ Service.Queue.router ~back:"/" "/admin/queue" ]
;;
