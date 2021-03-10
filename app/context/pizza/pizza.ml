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

let create name ingredients =
  let pizza = Model.create name ingredients in
  Repo.insert_pizza pizza
;;
