(* This is the entry point to the Sihl app.

   The parts of your app come together here and are wired to the services. This
   is also the central registry for infrastructure services. *)

let services =
  [ Sihl.Database.register ()
  ; Service.Migration.(
      register
        ~migrations:[ Database.Pizza.migration; Database.Pizza.migration ]
        ())
  ; Sihl.Web.Http.register
      ~middlewares:Routes.global_middlewares
      (Sihl.Web.choose [ Routes.site_public; Routes.site_private_; Routes.api ])
  ; Service.User.register ()
  ; Service.Queue.register
      ~jobs:
        [ Sihl_queue.hide Job.cook_pizza; Sihl_queue.hide Job.order_ingredient ]
      ()
  ]
;;

let () =
  Sihl.App.(
    empty
    |> with_services services
    |> run
         ~commands:
           (List.concat
              [ Command.all; [ Gen.service; Gen.view; Gen.html; Gen.json ] ]))
;;
