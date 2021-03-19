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
    make
      Field.
        [ string
            ~validator:(fun name ->
              if String.length name > 12
              then Some "The name is too long, it has to be less than 12"
              else if String.equal "" name
              then Some "The name can not be empty"
              else None)
            "name"
        ; bool "is_vegan"
        ; int
            ~validator:(fun price ->
              if price >= 0 && price <= 10000
              then None
              else Some "Price has to be positive and less than 10'000")
            "price"
        ]
      create_ingredient)
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
