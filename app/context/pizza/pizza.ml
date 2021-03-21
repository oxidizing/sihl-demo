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

module type SERVICE = sig
  type t

  val find : string -> t option Lwt.t
  val query : unit -> t list Lwt.t
  val create : string -> bool -> int -> (t, string) result Lwt.t
  val update : t -> (t, string) result Lwt.t
  val delete : t -> unit Lwt.t
end

module Ingredient : SERVICE with type t = ingredient = struct
  type t = ingredient

  let find name = Repo.find_ingredient name
  let query = Repo.find_ingredients

  let create name is_vegan price : (ingredient, string) Result.t Lwt.t =
    let open Lwt.Syntax in
    let* ingredient = find name in
    match ingredient with
    | None ->
      let ingredient = create_ingredient name is_vegan price in
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

  let update (ingredient : ingredient) =
    let open Lwt.Syntax in
    let* () = Repo.update_ingredient ingredient in
    let* updated = Repo.find_ingredient ingredient.name in
    match updated with
    | Some updated -> Lwt.return (Ok updated)
    | None -> Lwt.return @@ Error "Failed to update ingredient"
  ;;

  let delete (ingredient : ingredient) = Repo.delete_ingredient ingredient
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
