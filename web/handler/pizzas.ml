let index req =
  let user = Sihl.Web.User.find req in
  Lwt.return @@ Sihl.Web.Response.of_html (View.Pizzas.index user)
;;

let create _ = failwith "todo"
let delete _ = failwith "todo"
