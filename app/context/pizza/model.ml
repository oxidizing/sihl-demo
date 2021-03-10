(* This defines our pizza model *)
(* These models are pure and are used by other parts of the application, like the services *)

(* We use some ppx for convenience *)
(* make is used to construct a pizza model from data fetched from the database *)

(* This creates a pizza model with a randomized id *)

type ingredient =
  { name : string
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }

let create_ingredient name =
  { name; created_at = Ptime_clock.now (); updated_at = Ptime_clock.now () }
;;

type t =
  { name : string
  ; ingredients : ingredient list
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }

let create_pizza name ingredients =
  { name; ingredients; created_at = Ptime_clock.now (); updated_at = Ptime_clock.now () }
;;
