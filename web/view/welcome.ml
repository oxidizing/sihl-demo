open Tyxml

let page user =
  let welcome = [%html {|<span>Welcome to Vinnie's Pizza Place.</span>|}] in
  Layout.page user [ welcome ]
;;
