open Lwt.Syntax

let create_ingredient _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.Ingredient.create "ham" true 10 in
  let* _ = Pizza.Ingredient.create "tomato" true 2 in
  let* (ham : Pizza.ingredient) =
    Pizza.Ingredient.find "ham" |> Lwt.map Option.get
  in
  let* (tomato : Pizza.ingredient) =
    Pizza.Ingredient.find "tomato" |> Lwt.map Option.get
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

let create_pizza_without_ingredients _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.create_pizza "boring" [] in
  let* (pizza : Pizza.t) = Pizza.find_pizza "boring" |> Lwt.map Option.get in
  Alcotest.(check string "created boring pizza" "boring" pizza.Pizza.name);
  Lwt.return ()
;;

let create_pizza_with_ingredients _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.create_pizza "prosciutto" [ "ham"; "tomato" ] in
  let* (pizza : Pizza.t) =
    Pizza.find_pizza "prosciutto" |> Lwt.map Option.get
  in
  Alcotest.(check string "created prosciutto" "prosciutto" pizza.Pizza.name);
  Alcotest.(
    check
      (list string)
      "has ingredients"
      [ "ham"; "tomato" ]
      pizza.Pizza.ingredients);
  let* (ham : Pizza.ingredient) =
    Pizza.Ingredient.find "ham" |> Lwt.map Option.get
  in
  Alcotest.(check string "has created ingredient" "ham" ham.Pizza.name);
  Lwt.return ()
;;

let delete_pizza_with_ingredients _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.create_pizza "prosciutto" [ "ham"; "tomato" ] in
  let* (pizza : Pizza.t) =
    Pizza.find_pizza "prosciutto" |> Lwt.map Option.get
  in
  Alcotest.(check string "created prosciutto" "prosciutto" pizza.Pizza.name);
  let* () = Pizza.delete_pizza pizza in
  let* pizza = Pizza.find_pizza "prosciutto" in
  Alcotest.(check bool "has deleted pizza" true (Option.is_none pizza));
  let* (ham : Pizza.ingredient) =
    Pizza.Ingredient.find "ham" |> Lwt.map Option.get
  in
  Alcotest.(check string "has not deleted ingredient" "ham" ham.Pizza.name);
  let* (tomato : Pizza.ingredient) =
    Pizza.Ingredient.find "tomato" |> Lwt.map Option.get
  in
  Alcotest.(
    check string "has not deleted ingredient" "tomato" tomato.Pizza.name);
  Lwt.return ()
;;

let find_pizzas _ () =
  let* () = Sihl.Cleaner.clean_all () in
  let* () = Pizza.clean () in
  let* _ = Pizza.create_pizza "boring" [] in
  let* _ = Pizza.create_pizza "proscioutto" [ "ham"; "tomato" ] in
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
    [ ( "delicious test suite"
      , [ test_case "create ingredient" `Quick create_ingredient
        ; test_case "delete ingredient" `Quick delete_ingredient
        ; test_case "find ingredients" `Quick find_ingredients
        ; test_case
            "create pizza without ingredients"
            `Quick
            create_pizza_without_ingredients
        ; test_case
            "create pizza with ingredients"
            `Quick
            create_pizza_with_ingredients
        ; test_case
            "delete pizza with ingredients"
            `Quick
            delete_pizza_with_ingredients
        ; test_case "find pizzas" `Quick find_pizzas
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
     let* () = Service.Migration.execute [ Database.Pizza.migration ] in
     Alcotest_lwt.run "tests" suite)
;;
