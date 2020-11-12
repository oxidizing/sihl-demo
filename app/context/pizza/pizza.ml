let cleaner = Repo.clean

let create ctx name ingredients =
  let pizza = Model.create name ingredients in
  Repo.insert_pizza ctx pizza
;;
