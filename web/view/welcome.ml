open Tyxml

let page =
  let welcome = [%html {|<span>Welcome to Vinnie's Pizza Place.</span>|}] in
  Layout.page [ welcome ]
;;
