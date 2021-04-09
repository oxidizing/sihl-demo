let service =
  Sihl.Command.make
    ~name:"gen.service"
    ~help:
      "<service name> <name>:<type> <name>:<type> <name>:<type> ... \n\
       Supported types are: int, float, bool, string, datetime"
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
       Supported types are: int, float, bool, string, datetime"
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
    ~help:
      "<name> <name>:<type> <name>:<type> <name>:<type> ... \n\
       Supported types are: int, float, bool, string, datetime"
    ~description:
      "Generates a controller, views, a service, tests and migrations for an \
       HTML resource."
    (function
      | service_name :: schema ->
        (match Gen_core.schema_of_string schema with
        | Ok schema ->
          let module_ = String.capitalize_ascii service_name in
          Gen_service.generate service_name schema;
          Gen_view.generate service_name schema;
          print_endline
          @@ Format.sprintf
               {|
Resource '%ss' created.

Copy this route

    let %s =
      Sihl.Web.choose
        ~middlewares:
          [ Sihl.Web.Middleware.csrf ()
          ; Sihl.Web.Middleware.flash ()
          ]
        (Rest.resource
          "%ss"
          %s.schema
          (module %s : Rest.SERVICE with type t = %s.t)
          (module View_%s : Rest.VIEW with type t = %s.t))
    ;;

into your `routes/routes.ml` and mount it with the HTTP service. Don't forget to add '%s' and 'view_%s' to routes/dune.

Add the migration

    Database.%s.all

to the list of migrations before running `sihl migrate`.
You should also run `make format` to apply your styling rules.
|}
               service_name
               service_name
               service_name
               module_
               module_
               module_
               module_
               service_name
               service_name
               service_name
               module_;
          Lwt.return @@ Some ()
        | Error msg ->
          print_endline msg;
          raise @@ Sihl.Command.Exception "")
      | [] -> Lwt.return @@ None)
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
