let clean_pizzas_request =
  Caqti_request.exec Caqti_type.unit "TRUNCATE TABLE pizzas CASCADE;"
;;

let clean_ingredients_request =
  Caqti_request.exec Caqti_type.unit "TRUNCATE TABLE ingredients CASCADE;"
;;

let clean_pizzas_ingredients_request =
  Caqti_request.exec
    Caqti_type.unit
    "TRUNCATE TABLE pizzas_ingredients CASCADE;"
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
          $2 AT TIME ZONE 'UTC',
          $3 AT TIME ZONE 'UTC'
        )
        |sql}
;;

let insert_ingredient (ingredient : Model.ingredient) =
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.exec
        insert_ingredient_request
        ( ingredient.Model.name
        , ingredient.Model.created_at
        , ingredient.Model.updated_at ))
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
       (fun (name, created_at, updated_at) ->
         Model.{ name; created_at; updated_at })
       ingredient
;;

let find_ingredients_request =
  Caqti_request.collect
    Caqti_type.unit
    Caqti_type.(tup3 string ptime ptime)
    {sql|
        SELECT
          name,
          created_at,
          updated_at
        FROM ingredients
        |sql}
;;

let find_ingredients () : Model.ingredient list Lwt.t =
  let open Lwt.Syntax in
  let* ingredients =
    Sihl.Database.query' (fun connection ->
        let module Connection = (val connection : Caqti_lwt.CONNECTION) in
        Connection.collect_list find_ingredients_request ())
  in
  Lwt.return
  @@ List.map
       ~f:(fun (name, created_at, updated_at) ->
         Model.{ name; created_at; updated_at })
       ingredients
;;

let find_ingredients_of_pizza_request =
  Caqti_request.collect
    Caqti_type.string
    Caqti_type.(tup3 string ptime ptime)
    {sql|
        SELECT
          ingredients.name,
          ingredients.created_at,
          ingredients.updated_at
        FROM ingredients
        INNER JOIN pizzas_ingredients
        ON ingredients.id = pizzas_ingredients.ingredient_id
        INNER JOIN pizzas
        ON pizzas.id = pizzas_ingredients.pizza_id
        AND pizzas.name = ?
        |sql}
;;

let find_ingredients_of_pizza (name : string) : Model.ingredient list Lwt.t =
  let open Lwt.Syntax in
  let* ingredients =
    Sihl.Database.query' (fun connection ->
        let module Connection = (val connection : Caqti_lwt.CONNECTION) in
        Connection.collect_list find_ingredients_of_pizza_request name)
  in
  Lwt.return
  @@ List.map
       ~f:(fun (name, created_at, updated_at) ->
         Model.{ name; created_at; updated_at })
       ingredients
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

let find_pizza_request =
  Caqti_request.find_opt
    Caqti_type.string
    Caqti_type.(tup3 string ptime ptime)
    {sql|
        SELECT
          name,
          created_at,
          updated_at
        FROM pizzas
        WHERE name = ?
        |sql}
;;

let find_pizza name =
  let open Lwt.Syntax in
  let* pizza =
    Sihl.Database.query' (fun connection ->
        let module Connection = (val connection : Caqti_lwt.CONNECTION) in
        Connection.find_opt find_pizza_request name)
  in
  let* ingredients = find_ingredients_of_pizza name in
  let ingredients =
    List.map
      ~f:(fun (ingredient : Model.ingredient) -> ingredient.Model.name)
      ingredients
  in
  Lwt.return
  @@ Option.map
       (fun (name, created_at, updated_at) ->
         Model.{ name; ingredients; created_at; updated_at })
       pizza
;;

let find_pizzas_request =
  Caqti_request.collect
    Caqti_type.unit
    Caqti_type.(tup3 string ptime ptime)
    {sql|
        SELECT
          name,
          created_at,
          updated_at
        FROM pizzas
        |sql}
;;

let find_pizzas () : Model.t list Lwt.t =
  let open Lwt.Syntax in
  let* pizzas =
    Sihl.Database.query' (fun connection ->
        let module Connection = (val connection : Caqti_lwt.CONNECTION) in
        Connection.collect_list find_pizzas_request ())
  in
  List.map
    ~f:(fun (name, created_at, updated_at) ->
      Model.{ name; ingredients = []; created_at; updated_at })
    pizzas
  |> Lwt.return
;;

let insert_pizza_request =
  Caqti_request.exec
    Caqti_type.(tup3 string ptime ptime)
    {sql|
        INSERT INTO pizzas (
          name,
          created_at,
          updated_at
        ) VALUES (
          $1,
          $2 AT TIME ZONE 'UTC',
          $3 AT TIME ZONE 'UTC'
        )
    |sql}
;;

let insert_pizza_ingredient_request =
  Caqti_request.exec
    Caqti_type.(tup2 string string)
    {sql|
        INSERT INTO pizzas_ingredients (
          pizza_id,
          ingredient_id
        ) VALUES (
          (SELECT id FROM pizzas WHERE pizzas.name = $1),
          (SELECT id FROM ingredients WHERE ingredients.name = $2)
        )
    |sql}
;;

let insert_pizza (pizza : Model.t) (ingredients : string list) =
  let open Lwt_result.Syntax in
  Sihl.Database.transaction' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      let* () =
        Connection.exec
          insert_pizza_request
          (pizza.Model.name, pizza.Model.created_at, pizza.Model.updated_at)
      in
      let* () =
        Connection.populate
          ~table:"ingredients"
          ~columns:[ "name" ]
          Caqti_type.string
          (Caqti_lwt.Stream.of_list ingredients)
        |> Lwt.map Caqti_error.uncongested
      in
      List.fold_left
        ~f:(fun result ingredient ->
          let* () = result in
          Connection.exec
            insert_pizza_ingredient_request
            (pizza.Model.name, ingredient))
        ~init:(Lwt_result.return ())
        ingredients)
;;

let add_ingredient_to_pizza pizza ingredient =
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.exec insert_pizza_ingredient_request (pizza, ingredient))
;;

let delete_pizza_request =
  Caqti_request.exec
    Caqti_type.string
    {sql|
        DELETE FROM pizzas
        WHERE name = ?
        |sql}
;;

let delete_pizza (pizza : Model.t) : unit Lwt.t =
  (* We don't need to remove the pizzas_ingredients entry because of CASCADING *)
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.exec delete_pizza_request pizza.Model.name)
;;
