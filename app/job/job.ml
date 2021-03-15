let cook_pizza =
  Sihl_queue.create
    (fun pizza_name ->
      Pizza.create_pizza pizza_name [] |> Lwt.map ignore |> Lwt.map Result.ok)
    "cook-pizza"
;;

let order_ingredient =
  Sihl_queue.create
    (fun ingredient_name ->
      Pizza.create_ingredient ingredient_name
      |> Lwt.map ignore
      |> Lwt.map Result.ok)
    "order-ingredient"
;;
