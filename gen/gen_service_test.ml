let template =
  {|
open Lwt.Syntax

let create _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = {{module}}.clean () in
  let* t1 = {{module}}.create {{create_values}} in
  let* t2 = {{module}}.create "tomato" true 2 in
  let* (t1 : {{module}}.t) =
    {{module}}.find t1.{{module}}.id |> Lwt.map Option.get
  in
  let* (t2 : {{module}}.t) =
    {{module}}.find t2.{{module}}.id |> Lwt.map Option.get
  in
  Alcotest.(check string "has ham" "ham" ham.Pizza.name);
  Alcotest.(check string "has tomato" "tomato" tomato.Pizza.name);
  Lwt.return ()
;;

let delete_ingredient _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.Ingredient.create "ham" true 10 in
  let* (ham : Pizza.ingredient) =
    Pizza.Ingredient.find "ham" |> Lwt.map Option.get
  in
  Alcotest.(check string "has ham" "ham" ham.Pizza.name);
  let* _ = Pizza.Ingredient.delete ham in
  let* ham = Pizza.Ingredient.find "ham" in
  Alcotest.(check bool "has deleted ham" true (Option.is_none ham));
  Lwt.return ()
;;

let find_ingredients _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.Ingredient.create "ham" true 4 in
  let* _ = Pizza.Ingredient.create "tomato" true 2 in
  let* (ingredients : string list) =
    Pizza.Ingredient.query ()
    |> Lwt.map
         (List.map ~f:(fun (ingredient : Pizza.ingredient) ->
              ingredient.Pizza.name))
  in
  Alcotest.(check (list string) "has pizza" [ "tomato"; "ham" ] ingredients);
  Lwt.return ()
;;

let suite =
  Alcotest_lwt.
    [ ( "crud {{name}}"
      , [ test_case "create" `Quick create
        ; test_case "delete" `Quick delete
        ; test_case "find" `Quick finds
        ] )
    ]
;;

let services =
  [ Sihl.Database.register (); Sihl.Database.Migration.PostgreSql.register () ]
;;

let () =
  let open Lwt.Syntax in
  Unix.putenv "DATABASE_URL" "postgres://admin:password@127.0.0.1:5432/dev";
  Logs.set_level (Sihl.Log.get_log_level ());
  Logs.set_reporter (Sihl.Log.cli_reporter ());
  Lwt_main.run
    (let* _ = Sihl.Container.start_services services in
     let* () = Service.Migration.execute Database.Migration.all in
     Alcotest_lwt.run "{{name}}" suite)
;;
|}
;;

let dune_file_template =
  {|
(test
 (name test)
 (libraries sihl service database alcotest alcotest-lwt
   caqti-driver-postgresql {{name}}))
|}
;;

let create_values (schema : Gen_core.schema) =
  schema
  |> List.map ~f:snd
  |> List.map ~f:Gen_core.gen_type_to_example
  |> String.concat ~sep:" "
;;

let test_file (name : string) (schema : Gen_core.schema) =
  let params =
    [ "name", name
    ; "module", CCString.capitalize_ascii name
    ; "create_values", create_values schema
    ]
  in
  Gen_core.{ name = "test.ml"; template; params }
;;

let dune_file (name : string) =
  let params = [ "name", name ] in
  Gen_core.{ name = "test.ml"; template; params }
;;
