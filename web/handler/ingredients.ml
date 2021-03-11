let index _ =
  let open Lwt.Syntax in
  let* ingredients = Pizza.find_ingredients () in
  Lwt.return @@ Sihl.Web.Response.of_html (View.Ingredient.index ingredients)
;;

let create _ = failwith "todo"
let delete _ = failwith "todo"
