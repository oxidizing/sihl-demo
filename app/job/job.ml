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
      Pizza.create_ingredient ingredient_name
      |> Lwt.map ignore
      |> Lwt.map Result.ok)
    (fun s -> s)
    (fun s -> Ok s)
    "order-ingredient"
;;
