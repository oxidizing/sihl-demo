type gen_type =
  | Float
  | Int
  | Bool
  | String
  | Date
  | Time

let ocaml_type_of_gen_type = function
  | Float -> "float"
  | Int -> "int"
  | Bool -> "bool"
  | String -> "string"
  | Date -> "Ptime.date"
  | Time -> "Ptime.t"
;;

let gen_type_of_string (s : string) : (gen_type, string) result =
  match s with
  | "float" -> Ok Float
  | "Int" -> Ok Int
  | "Bool" -> Ok Bool
  | "String" -> Ok String
  | "Date" -> Ok Date
  | "Time" -> Ok Time
  | s -> Error (Format.sprintf "Invalid type '%s' provided" s)
;;

type schema = (string * gen_type) list

let schema_of_string (s : string list) : (schema, string) result =
  s
  |> List.map ~f:(String.split_on_char ~sep:':')
  |> List.map ~f:(fun s ->
         match s with
         | [ name; type_ ] -> Ok (name, type_)
         | _ ->
           Error
             (Format.sprintf
                "Invalid input provided '%s'"
                (String.concat ~sep:":" s)))
  |> List.fold_left
       ~f:(fun schema next ->
         match schema, next with
         | Ok schema, Ok (name, type_) ->
           (match gen_type_of_string type_ with
           | Ok gen_type -> Ok (List.cons (name, gen_type) schema)
           | Error msg -> Error msg)
         | Error msg, _ -> Error msg
         | Ok _, Error msg -> Error msg)
       ~init:(Result.ok [])
;;

let render template params =
  List.fold_left
    ~f:(fun res (name, value) ->
      CCString.replace
        ~which:`All
        ~sub:(Format.sprintf "{{%s}}" name)
        ~by:value
        res)
    ~init:template
    params
;;

let write_file (template : string) (params : (string * string) list) path : unit
  =
  let content = render template params in
  try
    CCIO.File.write_exn content path;
    print_endline (Format.sprintf "Wrote file '%s'" path)
  with
  | _ -> print_endline (Format.sprintf "Failed to write file '%s'" path)
;;
