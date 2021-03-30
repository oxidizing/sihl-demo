let model_type (schema : Gen_core.schema) =
  schema
  |> List.map ~f:(fun (name, type_) ->
         Format.sprintf "%s: %s" name (Gen_core.ocaml_type_of_gen_type type_))
  |> String.concat ~sep:","
  |> Format.sprintf "{%s}"
;;

let ctor_type (schema : Gen_core.schema) =
  schema
  |> List.map ~f:snd
  |> List.map ~f:Gen_core.ocaml_type_of_gen_type
  |> String.concat ~sep:" "
  |> Format.sprintf "%s -> t"
;;
