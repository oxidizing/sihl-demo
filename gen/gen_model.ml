let template =
  {|
type t =
  { id : string
  {{model_type}}
  ; created_at : Ptime.t
  ; updated_at : Ptime.t
  }
[@@deriving show]

let create {{create_args}} =
  let now = Ptime_clock.now () in
  let id = Uuidm.create `V4 |> Uuidm.to_string in
  { id; {{created_value}} created_at = now; updated_at = now }
;;

let[@warning "-45"] schema
    : (unit, {{ctor_type}}, t) Conformist.t
  =
  Conformist.(
    make
      Field.[
        {{conformist_fields}}
        ]
      create)
;;
|}
;;

let model_type (schema : Gen_core.schema) =
  schema
  |> List.map ~f:(fun (name, type_) ->
         Format.sprintf "%s: %s" name (Gen_core.ocaml_type_of_gen_type type_))
  |> String.concat ~sep:";"
  |> Format.sprintf ";%s"
;;

let ctor_type (schema : Gen_core.schema) =
  schema
  |> List.map ~f:snd
  |> List.map ~f:Gen_core.ocaml_type_of_gen_type
  |> String.concat ~sep:" -> "
  |> Format.sprintf "%s -> t"
;;

let create_args (schema : Gen_core.schema) =
  schema |> List.map ~f:fst |> String.concat ~sep:" "
;;

let created_value (schema : Gen_core.schema) =
  schema
  |> List.map ~f:fst
  |> List.map ~f:(Format.sprintf "%s;")
  |> String.concat ~sep:" "
;;

(* string "name"; bool "is_vegan"; int "price" *)
let conformist_fields (schema : Gen_core.schema) =
  schema
  |> List.map ~f:(fun (name, type_) ->
         Format.sprintf
           {|%s "%s"|}
           (Gen_core.conformist_type_of_gen_type type_)
           name)
  |> String.concat ~sep:"; "
;;

let file (schema : Gen_core.schema) =
  let params =
    [ "model_type", model_type schema
    ; "create_args", create_args schema
    ; "created_value", created_value schema
    ; "ctor_type", ctor_type schema
    ; "conformist_fields", conformist_fields schema
    ]
  in
  Gen_core.{ name = "model.ml"; template; params }
;;
