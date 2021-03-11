type ingredient =
  { name : string
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }

type t =
  { name : string
  ; ingredients : ingredient list
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }

exception Exception of string

val clean : unit -> unit Lwt.t

(** Ingredients *)

val create_ingredient : string -> ingredient Lwt.t
val find_ingredient : string -> ingredient option Lwt.t
val delete_ingredient : ingredient -> unit Lwt.t
val create_ingredients_if_not_exists : string list -> ingredient list Lwt.t

(** Pizzas *)

val create_pizza : string -> ingredient list -> t
val add_ingredient_to_pizza : string -> ingredient -> unit Lwt.t
val add_ingredients_to_pizza : t -> ingredient list -> unit Lwt.t
val create : string -> string list -> t Lwt.t
val find : string -> t option Lwt.t
val delete : t -> unit Lwt.t
