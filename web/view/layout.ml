open Tyxml

let%html navigation =
  {|
<ul>
  <li><a href="/">Welcome</a></li>
  <li><a href="/ingredients">Ingredients</a></li>
  <li><a href="/pizzas">pizzas</a></li>
  <li><a href="/customer/login">Login</a></li>
  <li><a href="/customer/registration">Registration</a></li>
</ul>
|}
;;

let%html page body =
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
    [ navigation ]
    body
    {|
     </body>
</html>
|}
;;
