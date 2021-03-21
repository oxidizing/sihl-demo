let create_pizza =
  Sihl.Command.make
    ~name:"pizza.create"
    ~help:"<pizza name> <ingredient1> <ingredient2> ..."
    ~description:"Create a pizza"
    (fun args ->
      match args with
      | name :: ingredients ->
        Pizza.create_pizza name ingredients |> Lwt.map ignore
      | _ ->
        raise
          (Sihl.Command.Exception
             "Usage: <pizza name> <ingredient1> <ingredient2> ..."))
;;

let cook_pizza =
  Sihl.Command.make
    ~name:"pizza.cook"
    ~help:"<pizza name>"
    ~description:"Starts cooking a pizza in 2 minutes"
    (fun args ->
      match args with
      | [ name ] ->
        Service.Queue.dispatch
          ~delay:(Sihl.Time.Span.minutes 2)
          name
          Job.cook_pizza
      | _ -> raise (Sihl.Command.Exception "Usage: <pizza name>"))
;;

let order_ingredient =
  Sihl.Command.make
    ~name:"pizza.ingredient.order"
    ~help:"<ingredient name>"
    ~description:"Orders ingredients that will be shipped in 30 seconds"
    (fun args ->
      match args with
      | [ name ] ->
        Service.Queue.dispatch
          ~delay:(Sihl.Time.Span.minutes 2)
          name
          Job.order_ingredient
      | _ -> raise (Sihl.Command.Exception "Usage: <ingredient name>"))
;;
