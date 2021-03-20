type ingredient =
  { name : string
  ; is_vegan : bool
  ; price : int
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }

type t =
  { name : string
  ; ingredients : string list
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }

exception Exception of string

val clean : unit -> unit Lwt.t

(** Ingredients *)

val find_ingredient : string -> ingredient option Lwt.t
val find_ingredients : unit -> ingredient list Lwt.t

val create_ingredient
  :  string
  -> bool
  -> int
  -> (ingredient, string) result Lwt.t

val update_ingredient : ingredient -> (ingredient, string) result Lwt.t
val delete_ingredient : ingredient -> unit Lwt.t

(** Pizzas *)

val find_pizza : string -> t option Lwt.t
val find_pizzas : unit -> t list Lwt.t
val add_ingredient_to_pizza : string -> ingredient -> unit Lwt.t
val create_pizza : string -> string list -> t Lwt.t
val delete_pizza : t -> unit Lwt.t
