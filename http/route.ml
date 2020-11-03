let hello_page = Sihl.Http.Route.get "/hello/" Handler.hello_page
let site_router = Sihl.Http.Route.router ~scope:"/page" [ hello_page ]
let api_router = Sihl.Http.Route.router ~scope:"/api" [ hello_page ]
let all = [ site_router; api_router ]
