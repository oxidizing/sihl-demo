let run =
  Sihl.Command.make
    ~name:"pizza.create"
    ~help:"<pizza name> <ingredient1> <ingredient2> ..."
    ~description:"Creates a pizza immediately."
    (fun args ->
      match args with
      | name :: ingredients ->
        Pizza.create_pizza name ingredients
        |> Lwt.map ignore
        |> Lwt.map Option.some
      | _ -> Lwt.return None)
;;
