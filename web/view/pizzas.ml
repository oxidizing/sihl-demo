open Tyxml

let index =
  let ingredients = [%html {|<span>List of pizzas.</span>|}] in
  Layout.page [ ingredients ]
;;
