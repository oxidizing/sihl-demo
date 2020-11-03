type t =
  { id : string
  ; name : string
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }
[@@deriving fields, show, eq]

let create ~name =
  { id = Database.Id.random () |> Database.Id.to_string
  ; name
  ; created_at = Ptime_clock.now ()
  ; updated_at = Ptime_clock.now ()
  }
;;

let t =
  let encode m = Ok (m.id, (m.name, (m.created_at, m.updated_at))) in
  let decode (id, (name, (created_at, updated_at))) =
    Ok { id; name; created_at; updated_at }
  in
  Caqti_type.(custom ~encode ~decode (tup2 string (tup2 string (tup2 ptime ptime))))
;;
