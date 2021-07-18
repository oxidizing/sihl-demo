(* This is the entry point to the Sihl app.

   The parts of your app come together here and are wired to the services. This
   is also the central registry for infrastructure services. *)

let services =
  [ Sihl.Database.register ()
  ; Service.Migration.(register ~migrations:[ Database.Pizza.migration ] ())
  ; Sihl.Web.Http.register ~middlewares:Routes.global_middlewares Routes.all
  ; Service.User.register ()
  ; Service.Queue.register ~jobs:Job.all ()
  ]
;;

let () = Sihl.App.(empty |> with_services services |> run ~commands:Command.all)
