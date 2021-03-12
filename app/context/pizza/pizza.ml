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

let find_ingredient name = Repo.find_ingredient name
let find_ingredients = Repo.find_ingredients

let create_ingredient name : (ingredient, string) Result.t Lwt.t =
  let open Lwt.Syntax in
  let* ingredient = find_ingredient name in
  match ingredient with
  | None ->
    let ingredient = create_ingredient name in
    let* () = Repo.insert_ingredient ingredient in
    let* ingredient = Repo.find_ingredient name in
    (match ingredient with
    | Some ingredient -> Lwt.return (Ok ingredient)
    | None ->
      Logs.err (fun m -> m "Failed to create ingredient '%s'" name);
      raise @@ Exception "Failed to create ingredient")
  | Some ingredient ->
    Lwt.return
      (Error (Format.sprintf "Ingredient '%s' already exists" ingredient.name))
;;

let delete_ingredient (ingredient : ingredient) =
  Repo.delete_ingredient ingredient
;;

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
