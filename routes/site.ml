(* All the HTML HTTP entry points are listed here.

   Don't put actual logic here to keep it declarative and easy to read. The
   overall scope of the web app should be clear after scanning the routes. *)

(* Public section *)
let welcome = Sihl.Web.Http.get "/" Handler.Welcome.index
let ingredient_index = Sihl.Web.Http.get "/ingredients" Handler.Ingredient.index
let ingredient_create = Sihl.Web.Http.put "/ingredients" Handler.Ingredient.create
let ingredient_delete = Sihl.Web.Http.delete "/ingredients/:id" Handler.Ingredient.delete
let pizza_index = Sihl.Web.Http.get "/pizzas" Handler.Pizza.index
let pizza_create = Sihl.Web.Http.put "/pizzas" Handler.Pizza.index
let pizza_delete = Sihl.Web.Http.delete "/pizzas/:id" Handler.Pizza.delete

(* Customer section *)
let login = Sihl.Web.Http.get "/login" Handler.Customer.login
let registration = Sihl.Web.Http.get "/login" Handler.Customer.registration
let order_index = Sihl.Web.Http.get "/orders" Handler.Customer.Order.index
let order_create = Sihl.Web.Http.put "/orders/:id" Handler.Customer.Order.create
let order_delete = Sihl.Web.Http.delete "/orders/:id" Handler.Customer.Order.delete

let middlewares =
  [ Opium.Middleware.content_length
  ; Opium.Middleware.etag
  ; Sihl.Web.Middleware.session ()
  ; Sihl.Web.Middleware.form
  ; Sihl.Web.Middleware.csrf ()
  ; Sihl.Web.Middleware.flash ()
  ]
;;

(* TODO [jerben] add authentiation and authorization middlewares *)
let router_customer =
  Sihl.Web.Http.router
    ~middlewares
    ~scope:"/customer"
    [ login; registration; order_index; order_create; order_delete ]
;;

let router_public =
  Sihl.Web.Http.router
    ~middlewares
    ~scope:"/"
    [ welcome
    ; ingredient_index
    ; ingredient_create
    ; ingredient_delete
    ; pizza_index
    ; pizza_create
    ; pizza_delete
    ]
;;
