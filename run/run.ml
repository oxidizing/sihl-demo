(* This is the entry point to the Sihl app.

   The parts of your app come together here and are wired to the services. This
   is also the central registry for infrastructure services. *)

let services =
  [ Sihl.Database.register ()
  ; Service.Migration.(register ~migrations:Database.Migration.all ())
  ; Sihl.Web.Http.register
      ~middlewares:Routes.Global.middlewares
      ~routers:
        [ Routes.Api.router
        ; Routes.Site.router_public
        ; Routes.Site.router_private
        ; Routes.Site.router_admin_queue
        ]
      ()
  ; Service.User.register ()
  ; Service.Queue.register ~jobs:[ Job.cook_pizza; Job.order_ingredient ] ()
  ]
;;

let () =
  Sihl.App.(
    empty
    |> with_services services
    |> run
         ~commands:
           [ Command.create_pizza
           ; Command.cook_pizza
           ; Command.order_ingredient
           ])
;;
