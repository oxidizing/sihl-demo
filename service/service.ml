module Migration = Sihl.Database.Migration.PostgreSql
module User = Sihl_user.PostgreSql
module Queue = Sihl_queue.PostgreSql

module MarketingSmtpConfig = struct
  let config () =
    Lwt.return
      Sihl_email.
        { sender = "marketing@vinniespiz.za"
        ; username = "vinnie"
        ; password = "pinapple0nPizz4"
        ; hostname = "smtp.example.com"
        ; port = Some 587
        ; start_tls = true
        ; ca_path = Some "/etc/ssl/certs"
        ; ca_cert = None
        ; console = Some true
        }
  ;;
end

module InfoSmtpConfig = struct
  let config () =
    let open Lwt.Syntax in
    Lwt_io.with_file ~mode:Lwt_io.Input "config/mail.cfg" (fun file ->
        let* content = Lwt_stream.to_list @@ Lwt_io.read_lines file in
        let config =
          content
          |> Stdlib.List.map (Stdlib.String.split_on_char '=')
          |> Stdlib.List.map (function
                 | [] -> "", ""
                 | [ key ] -> key, ""
                 | [ key; value ] -> key, value
                 | key :: values -> key, Stdlib.String.concat "" values)
        in
        Lwt.return
          Sihl_email.
            { sender = Stdlib.List.assoc "SMTP_SENDER" config
            ; username = Stdlib.List.assoc "SMTP_USERNAME" config
            ; password = Stdlib.List.assoc "SMTP_PASSWORD" config
            ; hostname = Stdlib.List.assoc "SMTP_HOST" config
            ; port =
                Option.map int_of_string
                @@ Stdlib.List.assoc_opt "SMTP_PORT" config
            ; start_tls =
                bool_of_string @@ Stdlib.List.assoc "SMTP_START_TLS" config
            ; ca_path = Stdlib.List.assoc_opt "CA_DIR" config
            ; ca_cert = Stdlib.List.assoc_opt "CA_PATH" config
            ; console =
                Option.map bool_of_string
                @@ Stdlib.List.assoc_opt "SMTP_CONSOLE" config
            })
  ;;
end

module MarketingMail = Sihl_email.MakeSmtp (MarketingSmtpConfig)
module InfoMail = Sihl_email.MakeSmtp (InfoSmtpConfig)
