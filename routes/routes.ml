(* All the HTML HTTP entry points are listed in this file.

   Don't put actual logic here and keep the routes declarative and easy to read.
   The overall scope of the web app should be clear after scanning the routes. *)

let global_middlewares =
  [ Sihl.Web.Middleware.id ()
  ; Sihl.Web.Middleware.error ()
  ; Sihl.Web.Middleware.static_file ()
  ; Opium.Middleware.method_override
  ]
;;

let site_middlewares =
  [ Opium.Middleware.content_length
  ; Sihl.Web.Middleware.csrf ()
  ; Sihl.Web.Middleware.flash ()
  ]
;;

let site_public =
  Sihl.Web.choose
    ~middlewares:site_middlewares
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
  Sihl.Web.choose
    ~middlewares:private_middlewares
    (Sihl.Web.Rest.resource_of_service
       "ingredients"
       Pizza.ingredient_schema
       ~view:
         (module View.Ingredients : Sihl.Web.Rest.VIEW
           with type t = Pizza.ingredient)
       (module Pizza.Ingredient : Sihl.Web.Rest.SERVICE
         with type t = Pizza.ingredient))
;;

let api = Sihl.Web.choose ~scope:"/api" []
