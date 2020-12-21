let hello_page = Sihl.Http.Route.get "/hello/" Handler.hello_page
let public = [ hello_page ]
let api = [ hello_page ]

let all =
  [ Sihl.Http.Route.router ~scope:"/page" public
  ; Sihl.Http.Route.router ~scope:"/api" api
  ]
;;
