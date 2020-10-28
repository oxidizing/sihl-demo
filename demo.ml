(* Static service setup, the only service we use is the web server in this example. *)
module Service = struct
  module WebServer = Sihl.Web.Server.Service.Opium
end

let hello_page =
  Sihl.Web.Route.get "/hello/" (fun _ ->
      Sihl.Web.Res.(html |> set_body "Hello!") |> Lwt.return)

let endpoints = [ ("/page", [ hello_page ], []) ]

let services = [ Service.WebServer.configure endpoints [ ("PORT", "8082") ] ]

(* Creation of the actual app. *)

let () = Sihl.Core.App.(empty |> with_services services |> run)
