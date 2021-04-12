let cook_pizza =
  Sihl_queue.create_job
    (fun pizza_name ->
      Pizza.create_pizza pizza_name [] |> Lwt.map ignore |> Lwt.map Result.ok)
    (fun s -> s)
    (fun s -> Ok s)
    "cook-pizza"
;;

let order_ingredient =
  Sihl_queue.create_job
    (fun ingredient_name ->
      Pizza.Ingredient.create ingredient_name false 10 |> Lwt_result.map ignore)
    (fun s -> s)
    (fun s -> Ok s)
    "order-ingredient"
;;

let all = [ Sihl_queue.hide cook_pizza; Sihl_queue.hide order_ingredient ]
