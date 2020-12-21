open Lwt.Syntax

let test_suite = []
let services = []

let () =
  Logs.set_reporter Sihl.Log.default_reporter;
  Unix.putenv "SIHL_ENV" "test";
  Lwt_main.run
    (let* _ = Sihl.Container.start_services services in
     let* () = Service.Migration.run_all () in
     Alcotest_lwt.run "e2e tests" @@ test_suite)
;;
