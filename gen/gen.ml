let service =
  Sihl.Command.make
    ~name:"gen.service"
    ~help:"<service name> <name1>:<type> <name2>:<type> <name3>:<type> ..."
    ~description:"Generates a service, tests and migrations."
    (function
      | service_name :: schema ->
        (match Gen_core.schema_of_string schema with
        | Ok schema ->
          Gen_service.generate service_name schema;
          Lwt.return @@ Some ()
        | Error msg -> raise @@ Sihl.Command.Exception msg)
      | _ -> Lwt.return @@ None)
;;

let html =
  Sihl.Command.make
    ~name:"gen.html"
    ~help:"<name1>:<type> <name2>:<type> <name3>:<type> ..."
    ~description:
      "Generates a controller, views, a service, tests and migrations for an \
       HTML resource."
    (fun _ -> Lwt.return @@ Some ())
;;

let json =
  Sihl.Command.make
    ~name:"gen.json"
    ~help:"<name1>:<type> <name2>:<type> <name3>:<type> ..."
    ~description:
      "Generates a controller, views, a service, tests and migrations for a \
       JSON resource."
    (fun _ -> Lwt.return @@ Some ())
;;
