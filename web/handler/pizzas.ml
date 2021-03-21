let index req =
  let open Lwt.Syntax in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  Lwt.return @@ Sihl.Web.Response.of_html (View.Pizzas.index user)
;;

let create _ = failwith "todo pizza create"
let delete _ = failwith "todo pizza delete"
