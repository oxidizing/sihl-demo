(* This defines our pizza model *)
(* These models are pure and are used by other parts of the application, like
   the services *)

(* We use some ppx for convenience *)
(* make is used to construct a pizza model from data fetched from the database *)

(* This creates a pizza model with a randomized id *)

type ingredient =
  { name : string
  ; is_vegan : bool
  ; price : int
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }
[@@deriving show]

let create_ingredient name is_vegan price =
  { name
  ; is_vegan
  ; price
  ; created_at = Ptime_clock.now ()
  ; updated_at = Ptime_clock.now ()
  }
;;

let[@warning "-45"] ingredient_schema
    : (unit, string -> bool -> int -> ingredient, ingredient) Conformist.t
  =
  Conformist.(
    make Field.[ string "name"; bool "is_vegan"; int "price" ] create_ingredient)
;;

type t =
  { name : string
  ; ingredients : string list
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }

let create_pizza name ingredients =
  { name
  ; ingredients
  ; created_at = Ptime_clock.now ()
  ; updated_at = Ptime_clock.now ()
  }
;;
