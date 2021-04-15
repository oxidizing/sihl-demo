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

(* let create _ = failwith "todo pizza create" *)

let create req =
  let open Lwt.Syntax in
  let* name = Sihl.Web.Request.urlencoded "name" req in
  match name with
  | None ->
    Sihl.Web.Response.redirect_to "/pizzas"
    |> Sihl.Web.Flash.set_alert "Invalid input provided"
    |> Lwt.return
  | Some name ->
    let* ingredients = Sihl.Web.Request.urlencoded "ingredients" req in
    (match ingredients with
    | None ->
      Sihl.Web.Response.redirect_to "/pizzas"
      |> Sihl.Web.Flash.set_notice (Format.sprintf "Something went wrong")
      |> Lwt.return
    | Some ingredients ->
      if String.length ingredients < 1
      then
        (* Skip redirect, pass pizza name? *)
        Sihl.Web.Response.redirect_to "/pizzas"
        |> Sihl.Web.Flash.set_notice
             (Format.sprintf "What a boring pizza, please add some ingredients")
        |> Lwt.return
      else (
        let ingredients = Stringext.split ~on:',' ingredients in
        let open Containers in
        let ingredients_list = CCList.map String.trim ingredients in
        let* pizza = Pizza.create_pizza name ingredients_list in
        match pizza with
        | pizza ->
          Sihl.Web.Response.redirect_to "/pizzas"
          |> Sihl.Web.Flash.set_notice
               (Format.sprintf "Pizza '%s' added" pizza.Pizza.name)
          |> Lwt.return
        (* How to deal with errors - see ingredients ( | Ok ingredient )*)
        (* | _ -> Sihl.Web.Response.redirect_to "/ingredients" |>
           Sihl.Web.Flash.set_alert "An error occurred" |> Lwt.return*)))
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
