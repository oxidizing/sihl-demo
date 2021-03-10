open Lwt.Syntax

let create_ingredient _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.create_ingredient "ham" in
  let* _ = Pizza.create_ingredient "tomato" in
  let* (ham : Pizza.ingredient) = Pizza.find_ingredient "ham" |> Lwt.map Option.get in
  let* (tomato : Pizza.ingredient) =
    Pizza.find_ingredient "tomato" |> Lwt.map Option.get
  in
  Alcotest.(check string "has ham" "ham" ham.Pizza.name);
  Alcotest.(check string "has tomato" "tomato" tomato.Pizza.name);
  Lwt.return ()
;;

let delete_ingredient _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.create_ingredient "ham" in
  let* (ham : Pizza.ingredient) = Pizza.find_ingredient "ham" |> Lwt.map Option.get in
  Alcotest.(check string "has ham" "ham" ham.Pizza.name);
  let* _ = Pizza.delete_ingredient ham in
  let* ham = Pizza.find_ingredient "ham" in
  Alcotest.(check bool "has deleted ham" true (Option.is_none ham));
  Lwt.return ()
;;

let create_pizza_without_ingredients _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.create "boring" [] in
  let* (pizza : Pizza.t) = Pizza.find "boring" |> Lwt.map Option.get in
  Alcotest.(check string "created boring pizza" "boring" pizza.Pizza.name);
  Lwt.return ()
;;

let create_pizza_with_ingredients _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.create "prosciutto" [ "ham"; "tomato" ] in
  let* (pizza : Pizza.t) = Pizza.find "prosciutto" |> Lwt.map Option.get in
  Alcotest.(check string "created prosciutto" "prosciutto" pizza.Pizza.name);
  let ingredients =
    List.map
      ~f:(fun (ingredient : Pizza.ingredient) -> ingredient.Pizza.name)
      pizza.Pizza.ingredients
  in
  Alcotest.(check (list string) "has ingredients" [ "ham"; "tomato" ] ingredients);
  Lwt.return ()
;;

let suite =
  Alcotest_lwt.
    [ ( "delicious test suite"
      , [ test_case "create ingredient" `Quick create_ingredient
        ; test_case "delete ingredient" `Quick delete_ingredient
        ; test_case
            "create pizza without ingredients"
            `Quick
            create_pizza_without_ingredients
        ; test_case "create pizza with ingredients" `Quick create_pizza_with_ingredients
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
     Alcotest_lwt.run "tests" suite)
;;
