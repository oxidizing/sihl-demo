let cleaners = [ Pizza.cleaner ]
let routers = Http.Route.all
let migrations = Database.Migration.all

let services =
  [ Service.Repository.register ~cleaners ()
  ; Service.Migration.register ~migrations ()
  ; Service.Http.register ~routers ()
  ]
;;

let commands = [ Command.Create_pizza.run ]

let () =
  Sihl.App.(
    empty
    |> with_services services
    |> before_start (fun () ->
           Printexc.record_backtrace true;
           Lwt.return ())
    |> run ~commands)
;;
