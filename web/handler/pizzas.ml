let index req =
  let open Lwt.Syntax in
  let csrf = Sihl.Web.Csrf.find req |> Option.get in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let* pizzas = Pizza.find_pizzas () in
  Lwt.return
  @@ Sihl.Web.Response.of_html
       (View.Pizzas.index user ~alert ~notice csrf pizzas)
;;

let show req =
  let open Lwt.Syntax in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let name = Sihl.Web.Router.param req "name" in
  let* pizza = Pizza.find_pizza name in
  match pizza with
  | None ->
    Sihl.Web.Response.redirect_to "/pizzas"
    |> Sihl.Web.Flash.set_alert (Format.sprintf "Pizza '%s' not found" name)
    |> Lwt.return
  | Some pizza ->
    Lwt.return
    @@ Sihl.Web.Response.of_html (View.Pizzas.show user ~alert ~notice pizza)
;;

let create _ = failwith "todo pizza create"

let delete req =
  let open Lwt.Syntax in
  let name = Sihl.Web.Router.param req "name" in
  let* pizza = Pizza.find_pizza name in
  match pizza with
  | None ->
    Sihl.Web.Response.redirect_to "/pizzas"
    |> Sihl.Web.Flash.set_alert (Format.sprintf "Pizza '%s' not found" name)
    |> Lwt.return
  | Some pizza ->
    let* () = Pizza.delete_pizza pizza in
    Sihl.Web.Response.redirect_to "/pizzas"
    |> Sihl.Web.Flash.set_notice
         (Format.sprintf "Pizza '%s' removed" pizza.Pizza.name)
    |> Lwt.return
;;
