let service =
  Sihl.Command.make
    ~name:"gen.service"
    ~help:
      "<service name> <name>:<type> <name>:<type> <name>:<type> ... \n\
       Supported types: int, float, bool, string, datetime"
    ~description:"Generates a service, tests and migrations."
    (function
      | service_name :: schema ->
        (match Gen_core.schema_of_string schema with
        | Ok schema ->
          Gen_service.generate service_name schema;
          Lwt.return @@ Some ()
        | Error msg ->
          print_endline msg;
          raise @@ Sihl.Command.Exception "")
      | [] -> Lwt.return @@ None)
;;

let view =
  Sihl.Command.make
    ~name:"gen.view"
    ~help:
      "<name> <name>:<type> <name>:<type> <name>:<type> ... \n\
       Supported types: int, float, bool, string, datetime"
    ~description:"Generates an HTML view."
    (function
      | name :: schema ->
        (match Gen_core.schema_of_string schema with
        | Ok schema ->
          Gen_view.generate name schema;
          Lwt.return @@ Some ()
        | Error msg ->
          print_endline msg;
          raise @@ Sihl.Command.Exception "")
      | [] -> Lwt.return @@ None)
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
