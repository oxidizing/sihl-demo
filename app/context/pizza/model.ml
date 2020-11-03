type t =
  { id : string
  ; name : string
  ; ingredients : string list
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }
[@@deriving fields, show, eq, make]

let create name ingredients =
  { id = Sihl.Database.Id.random () |> Sihl.Database.Id.to_string
  ; name
  ; ingredients
  ; created_at = Ptime_clock.now ()
  ; updated_at = Ptime_clock.now ()
  }
;;

let t =
  let encode m = Ok (m.id, (m.name, (m.created_at, m.updated_at))) in
  let decode (id, (name, (created_at, updated_at))) =
    Ok { id; name; ingredients = []; created_at; updated_at }
  in
  Caqti_type.(custom ~encode ~decode (tup2 string (tup2 string (tup2 ptime ptime))))
;;
