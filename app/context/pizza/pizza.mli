type ingredient =
  { name : string
  ; is_vegan : bool
  ; price : int
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }

val ingredient_schema
  : (unit, string -> bool -> int -> ingredient, ingredient) Conformist.t

type t =
  { name : string
  ; ingredients : string list
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }

exception Exception of string

val clean : unit -> unit Lwt.t

(** Ingredients *)

module Ingredient : sig
  type t = ingredient

  val find : string -> t option Lwt.t
  val query : unit -> t list Lwt.t
  val create : string -> bool -> int -> (t, string) result Lwt.t
  val insert : t -> (t, string) result Lwt.t
  val update : string -> t -> (t, string) result Lwt.t
  val delete : t -> (unit, string) result Lwt.t
end

(** Pizzas *)

val find_pizza : string -> t option Lwt.t
val find_pizzas : unit -> t list Lwt.t
val add_ingredient_to_pizza : string -> ingredient -> unit Lwt.t
val create_pizza : string -> string list -> t Lwt.t
val delete_pizza : t -> unit Lwt.t
