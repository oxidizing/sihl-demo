let hello_page _ = Lwt.return @@ Sihl.Http.Response.of_plain_text "Hello"
