include Model

exception Exception of string

let clean =
  if Sihl.Configuration.is_production ()
  then
    raise
    @@ Exception
         "Can not clean repository in production, this is most likely not what \
          you want"
  else Repo.clean
;;

module Ingredient = struct
  type t = ingredient

  let find name = Repo.find_ingredient name

  let search ?filter:_ ?sort:_ ?limit:_ ?offset:_ () =
    Repo.find_ingredients () |> Lwt.map (fun v -> v, 0)
  ;;

  let insert (ingredient : ingredient) =
    let open Lwt.Syntax in
    let* found = find ingredient.name in
    match found with
    | None ->
      let* () = Repo.insert_ingredient ingredient in
      let* inserted = Repo.find_ingredient ingredient.name in
      (match inserted with
      | Some ingredient -> Lwt.return (Ok ingredient)
      | None ->
        Logs.err (fun m ->
            m "Failed to insert ingredient '%a'" pp_ingredient ingredient);
        Lwt.return @@ Error "Failed to insert ingredient")
    | Some _ ->
      Lwt.return
      @@ Error (Format.sprintf "Ingredient '%s' already exists" ingredient.name)
  ;;

  let create name is_vegan price : (ingredient, string) Result.t Lwt.t =
    let open Lwt.Syntax in
    let* ingredient = find name in
    match ingredient with
    | None ->
      let ingredient = create_ingredient name is_vegan price in
      insert ingredient
    | Some ingredient ->
      Lwt.return
        (Error (Format.sprintf "Ingredient '%s' already exists" ingredient.name))
  ;;

  let update _ (ingredient : ingredient) =
    let open Lwt.Syntax in
    let* () = Repo.update_ingredient ingredient in
    let* updated = Repo.find_ingredient ingredient.name in
    match updated with
    | Some updated -> Lwt.return (Ok updated)
    | None -> Lwt.return @@ Error "Failed to update ingredient"
  ;;

  let delete (ingredient : ingredient) =
    Repo.delete_ingredient ingredient |> Lwt.map Result.ok
  ;;
end

let add_ingredient_to_pizza (pizza : string) (ingredient : ingredient) =
  Repo.add_ingredient_to_pizza pizza ingredient.name
;;

let create_pizza name (ingredients : string list) : t Lwt.t =
  let open Lwt.Syntax in
  let pizza = Model.create_pizza name ingredients in
  let* () = Repo.insert_pizza pizza ingredients in
  let* pizza = Repo.find_pizza name in
  match pizza with
  | Some pizza -> Lwt.return pizza
  | None ->
    Logs.err (fun m -> m "Failed to create pizza '%s'" name);
    raise @@ Exception "Failed to create pizza"
;;

let find_pizza name = Repo.find_pizza name
let find_pizzas = Repo.find_pizzas
let delete_pizza (pizza : t) : unit Lwt.t = Repo.delete_pizza pizza
