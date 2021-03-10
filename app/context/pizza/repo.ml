let find_pizza_request =
  Caqti_request.find
    Caqti_type.string
    Caqti_type.(tup4 string string ptime ptime)
    {sql|
        SELECT
          uuid as id,
          name,
          created_at,
          updated_at
        FROM pizzas
        WHERE uuid = ?::uuid
        |sql}
;;

let find_pizza id =
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.find find_pizza_request id)
;;

let find_ingredients_for_pizza_request =
  Caqti_request.collect
    Caqti_type.string
    Caqti_type.(tup4 string string ptime ptime)
    {sql|
        SELECT
          pizza_id,
          ingredient,
          created_at,
          updated_at
        FROM pizzas_ingredients
       WHERE pizza_id = ?::uuid
        |sql}
;;

let find_ingredients_for_pizza id =
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.collect_list find_ingredients_for_pizza_request id)
;;

let insert_pizzas_request =
  Caqti_request.exec
    Caqti_type.(tup4 string string ptime ptime)
    {sql|
        INSERT INTO pizzas (
          uuid,
          name,
          created_at,
          updated_at
        ) VALUES (
          $1,
          $2,
          $3,
          $4
        )
        |sql}
;;

let insert_pizzas_ingredients_request =
  Caqti_request.exec
    Caqti_type.(tup4 string string ptime ptime)
    {sql|
        INSERT INTO pizzas_ingredients (
          pizza_id,
          ingredient,
          created_at,
          updated_at
        ) VALUES (
          $1,
          $2,
          $3,
          $4
        )
        |sql}
;;

let insert_pizza _ = failwith "insert_pizza"

(* let insert_pizza pizza =
 *   let open Lwt.Syntax in
 *   let pizza_ingredients =
 *     List.map ~f:(fun ingr -> pizza.Model.id, ingr) pizza.Model.ingredients
 *   in
 *   let pizza_tup =
 *     pizza.Model.id, pizza.Model.name, pizza.Model.created_at, pizza.Model.updated_at
 *   in
 *   Sihl.Database.transaction (fun connection ->
 *       let module Connection = (val connection : Caqti_lwt.CONNECTION) in
 *       let* res = Connection.exec insert_pizzas_request pizza_tup in
 *       let () =
 *         match res with
 *         | Ok hm -> hm
 *         | Error err -> failwith @@ Caqti_error.show err
 *       in
 *       let* res =
 *         Connection.populate
 *           ~table:"pizzas_ingredients"
 *           ~columns:[ "pizza_id"; "ingredient" ]
 *           Caqti_type.(tup2 string string)
 *           (Caqti_lwt.Stream.of_list pizza_ingredients)
 *       in
 *       let () =
 *         match res with
 *         | Ok _ -> ()
 *         | Error (`Congested _) -> Logs.err (fun m -> m "Congested")
 *         | res ->
 *           (match Caqti_error.uncongested res with
 *           | Ok _ -> ()
 *           | Error err -> failwith @@ Caqti_error.show err)
 *       in
 *       let* id, name, created_at, updated_at = find_pizza connection pizza.Model.id in
 *       let* ingredients =
 *         find_ingredients_for_pizza pizza.Model.id
 *         |> Lwt.map (List.map (fun (_, ingr, _, _) -> ingr))
 *       in
 *       Lwt.return @@ Model.make ~id ~name ~ingredients ~created_at ~updated_at ())
 * ;; *)

let clean_pizzas_request =
  Caqti_request.exec Caqti_type.unit "TRUNCATE TABLE pizzas CASCADE;"
;;

let clean_ingredients_request =
  Caqti_request.exec Caqti_type.unit "TRUNCATE TABLE ingredients CASCADE;"
;;

let clean_pizzas_ingredients_request =
  Caqti_request.exec Caqti_type.unit "TRUNCATE TABLE pizzas_ingredients CASCADE;"
;;

let clean () =
  let open Lwt_result.Syntax in
  Sihl.Database.query' (fun (module Connection : Caqti_lwt.CONNECTION) ->
      let* () = Connection.exec clean_pizzas_request () in
      let* () = Connection.exec clean_ingredients_request () in
      Connection.exec clean_pizzas_ingredients_request ())
;;

let insert_ingredient_request =
  Caqti_request.exec
    Caqti_type.(tup3 string ptime ptime)
    {sql|
        INSERT INTO ingredients (
          name,
          created_at,
          updated_at
        ) VALUES (
          $1,
          $2,
          $3
        )
        |sql}
;;

let insert_ingredient (ingredient : Model.ingredient) =
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.exec
        insert_ingredient_request
        (ingredient.Model.name, ingredient.Model.created_at, ingredient.Model.updated_at))
;;

let find_ingredient_request =
  Caqti_request.find_opt
    Caqti_type.string
    Caqti_type.(tup3 string ptime ptime)
    {sql|
        SELECT
          name,
          created_at,
          updated_at
        FROM ingredients
        WHERE name = ?
        |sql}
;;

let find_ingredient (name : string) : Model.ingredient option Lwt.t =
  let open Lwt.Syntax in
  let* ingredient =
    Sihl.Database.query' (fun connection ->
        let module Connection = (val connection : Caqti_lwt.CONNECTION) in
        Connection.find_opt find_ingredient_request name)
  in
  Lwt.return
  @@ Option.map
       (fun (name, created_at, updated_at) -> Model.{ name; created_at; updated_at })
       ingredient
;;

let delete_ingredient_request =
  Caqti_request.exec
    Caqti_type.string
    {sql|
        DELETE FROM ingredients
        WHERE name = ?
        |sql}
;;

let delete_ingredient (ingredient : Model.ingredient) : unit Lwt.t =
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.exec delete_ingredient_request ingredient.Model.name)
;;
