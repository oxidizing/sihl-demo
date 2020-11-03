let cleaners = [ Pizza.cleaner ]

let services =
  [ (* TODO [aerben] add cleaners after sihl updated *)
    Service.Repository.configure cleaners []
    (* TODO [aerben] add migrations after sihl updated *)
  ; Service.Migration.configure Database.Migration.all []
  ; Service.Database.configure [ "DATABASE_URL", "postgresql://admin@localhost:5432/dev" ]
  ; Service.Http.configure Http.Route.all [ "PORT", "8082" ]
  ]
;;

let () = Sihl.Core.App.(empty |> with_services services |> run)
