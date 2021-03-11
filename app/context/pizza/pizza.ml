include Model

let clean = Repo.clean

exception Exception of string

let create_ingredient name : ingredient Lwt.t =
  let open Lwt.Syntax in
  let ingredient = create_ingredient name in
  let* () = Repo.insert_ingredient ingredient in
  let* ingredient = Repo.find_ingredient name in
  match ingredient with
  | Some ingredient -> Lwt.return ingredient
  | None ->
    Logs.err (fun m -> m "Failed to create ingredient '%s'" name);
    raise @@ Exception "Failed to create ingredient"
;;

let find_ingredient name = Repo.find_ingredient name
let delete_ingredient (ingredient : ingredient) = Repo.delete_ingredient ingredient

let rec create_ingredients_if_not_exists (ingredients : string list)
    : ingredient list Lwt.t
  =
  let open Lwt.Syntax in
  match ingredients with
  | ingredient_name :: ingredients ->
    let* ingredient = find_ingredient ingredient_name in
    (match ingredient with
    | None ->
      let* ingredient = create_ingredient ingredient_name in
      let* ingredients = create_ingredients_if_not_exists ingredients in
      Lwt.return @@ List.cons ingredient ingredients
    | Some ingredient ->
      let* ingredients = create_ingredients_if_not_exists ingredients in
      Lwt.return @@ List.cons ingredient ingredients)
  | [] -> Lwt.return []
;;

let add_ingredient_to_pizza (pizza : string) (ingredient : ingredient) =
  Repo.add_ingredient_to_pizza pizza ingredient.name
;;

let rec add_ingredients_to_pizza (pizza : t) (ingredients : ingredient list) : unit Lwt.t =
  let open Lwt.Syntax in
  match ingredients with
  | ingredient :: ingredients ->
    let* () = add_ingredient_to_pizza pizza.name ingredient in
    add_ingredients_to_pizza pizza ingredients
  | [] -> Lwt.return ()
;;

let create name (ingredients : string list) : t Lwt.t =
  let open Lwt.Syntax in
  let* ingredients = create_ingredients_if_not_exists ingredients in
  let pizza = Model.create_pizza name ingredients in
  let* () = Repo.insert_pizza pizza in
  let* pizza = Repo.find_pizza name in
  match pizza with
  | Some pizza ->
    let* () = add_ingredients_to_pizza pizza ingredients in
    Lwt.return pizza
  | None ->
    Logs.err (fun m -> m "Failed to create pizza '%s'" name);
    raise @@ Exception "Failed to create pizza"
;;

let find name = Repo.find_pizza name
let delete (pizza : t) : unit Lwt.t = Repo.delete_pizza pizza
