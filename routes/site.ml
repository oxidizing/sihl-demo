(* All the HTML HTTP entry points are listed here.

   Don't put actual logic here to keep it declarative and easy to read. The
   overall scope of the web app should be clear after scanning the routes. *)

(* Public section *)
let welcome = Sihl.Web.Http.get "/" Handler.Welcome.index
let ingredient_index = Sihl.Web.Http.get "/ingredients" Handler.Ingredients.index
let ingredient_create = Sihl.Web.Http.post "/ingredients" Handler.Ingredients.create

let ingredient_delete =
  Sihl.Web.Http.post "/ingredients/:name/delete" Handler.Ingredients.delete
;;

let pizza_index = Sihl.Web.Http.get "/pizzas" Handler.Pizzas.index
let pizza_create = Sihl.Web.Http.post "/pizzas" Handler.Pizzas.index
let pizza_delete = Sihl.Web.Http.delete "/pizzas/:name" Handler.Pizzas.delete

(* Customer section *)
let login = Sihl.Web.Http.get "/login" Handler.Customers.login
let registration = Sihl.Web.Http.get "/login" Handler.Customers.registration
let order_index = Sihl.Web.Http.get "/orders" Handler.Customers.Order.index
let order_create = Sihl.Web.Http.post "/orders/:id" Handler.Customers.Order.create
let order_delete = Sihl.Web.Http.delete "/orders/:id" Handler.Customers.Order.delete

let middlewares =
  [ Opium.Middleware.content_length
  ; Opium.Middleware.etag
  ; Sihl.Web.Middleware.session ()
  ; Sihl.Web.Middleware.form
  ; Sihl.Web.Middleware.csrf ()
  ; Sihl.Web.Middleware.flash ()
  ]
;;

(* TODO [jerben] add authentication middleware *)
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
