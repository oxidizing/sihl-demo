let clean_request = Caqti_request.exec Caqti_type.unit "TRUNCATE TABLE pizza CASCADE;"

let clean ctx =
  Service.Database.query ctx (fun (module Connection : Caqti_lwt.CONNECTION) ->
      Connection.exec clean_request () |> Lwt.map Result.get_ok)
;;
