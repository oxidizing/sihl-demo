open Tyxml

let index _ =
  let ingredients = [%html {|<span>List of ingredients.</span>|}] in
  Layout.page [ ingredients ]
;;
