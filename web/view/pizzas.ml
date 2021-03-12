open Tyxml

let index user =
  let ingredients = [%html {|<span>List of pizzas.</span>|}] in
  Layout.page (Some user) [ ingredients ]
;;
