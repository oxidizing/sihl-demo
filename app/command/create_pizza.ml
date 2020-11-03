let run =
  Sihl.Core.Command.make
    ~name:"createpizza"
    ~help:"<pizza name> <ingredient1> <ingredient2> ..."
    ~description:"Create a pizza"
    (fun args ->
      match args with
      | name :: ingredients ->
        let ctx = Sihl.Core.Ctx.create () in
        Pizza.create ctx name ingredients |> Lwt.map ignore
      | _ ->
        raise
          (Sihl.Core.Command.Exception
             "Usage: <pizza name> <ingredient1> <ingredient2> ..."))
;;
