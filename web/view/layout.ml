open Tyxml

let navigation user =
  match user with
  | None ->
    [%html
      {|
      <header>
<ul class="nav">
  <li><a href="/login">Login</a></li>
  <li><a href="/registration">Registration</a></li>
</ul></header>
|}]
  | Some user ->
    [%html
      {|
<header>
  <div>|}
        [ Html.txt (Format.sprintf "Welcome %s!" user.Sihl.Contract.User.email)
        ]
        {|
  </div>
  <ul class="nav">
    <li><a href="/ingredients">Ingredients</a></li>
    <li><a href="/pizzas">Pizzas</a></li>
    <li><a href="/admin/queue">Queue Dashboard</a></li>
    <li><a href="/logout">Logout</a></li>
  </ul>
</header>|}]
;;

let%html page user body =
  {|
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
      <link href="/assets/reset.css" rel="stylesheet">
      <link href="/assets/styles.css" rel="stylesheet">
      <title>Hello world!</title>
  </head>
    <body>|}
    [ navigation user ]
    {|<main>|}
    body
    {|
      </main>
      </body>
</html>
|}
;;
