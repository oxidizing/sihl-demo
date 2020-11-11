open Lwt.Syntax

let test_suite = []
let services = []

let () =
  Logs.set_reporter (Sihl.Core.Log.default_reporter ());
  let ctx = Sihl.Core.Ctx.create () in
  let configurations =
    List.map (fun service -> Sihl.Core.Container.Service.configuration service) services
  in
  List.iter
    (fun configuration ->
      configuration |> Sihl.Core.Configuration.data |> Sihl.Core.Configuration.store)
    configurations;
  Lwt_main.run
    (let* _ = Sihl.Core.Container.start_services services in
     let* () = Service.Migration.run_all ctx in
     Alcotest_lwt.run "e2e" @@ test_suite)
;;
