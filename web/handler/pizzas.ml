let index req =
  let open Lwt.Syntax in
  let csrf = Sihl.Web.Csrf.find req |> Option.get in
  let alert = Sihl.Web.Flash.find_alert req in
  let notice = Sihl.Web.Flash.find_notice req in
  let* user = Service.User.Web.user_from_session req |> Lwt.map Option.get in
  let* pizzas = Pizza.find_pizzas () in
  let* ingredients = Pizza.find_ingredients () in
  Lwt.return
  @@ Sihl.Web.Response.of_html
       (View.Pizzas.index user ~alert ~notice csrf pizzas ingredients)
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

let create req =
  let open Lwt.Syntax in
  let* name = Sihl.Web.Request.urlencoded "name" req in
  match name with
  | None ->
    Sihl.Web.Response.redirect_to "/pizzas"
    |> Sihl.Web.Flash.set_alert "Invalid input provided"
    |> Lwt.return
  | Some name ->
    let* ingredients = Sihl.Web.Request.urlencoded_list "ingredients" req in
    if List.length ingredients < 1
    then
      Sihl.Web.Response.redirect_to "/pizzas"
      |> Sihl.Web.Flash.set_notice
           (Format.sprintf "Please select at least one ingredient")
      |> Lwt.return
    else
      let* pizza = Pizza.create_pizza name ingredients in
      (match pizza with
      | pizza ->
        Sihl.Web.Response.redirect_to "/pizzas"
        |> Sihl.Web.Flash.set_notice
             (Format.sprintf "Pizza '%s' added" pizza.Pizza.name)
        |> Lwt.return)
;;

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
