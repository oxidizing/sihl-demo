let cleaner () =
  Service.Repository.register_cleaner Repo.clean;
  Lwt.return ()
;;

let create name ingredients =
  let pizza = Model.create name ingredients in
  Repo.insert_pizza pizza
;;
