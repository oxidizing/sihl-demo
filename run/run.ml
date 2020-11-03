let cleaners = [ Pizza.cleaner ]

let services =
  [ Service.Repository.configure cleaners []
  ; Service.Migration.configure Database.Migration.all []
  ; Service.Database.configure []
  ; Service.Http.configure Http.Route.all [ "PORT", "8082" ]
  ]
;;

let commands = [ Command.Create_pizza.run ]
let () = Sihl.Core.App.(empty |> with_services services |> run ~commands)
