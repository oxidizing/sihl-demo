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
  | "int" -> Ok Int
  | "bool" -> Ok Bool
  | "string" -> Ok String
  | "date" -> Ok Date
  | "time" -> Ok Time
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

type file =
  { name : string
  ; template : string
  ; params : (string * string) list
  }

let render { template; params; _ } =
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

let write_file (file : file) (path : string) : unit =
  let content = render file in
  let filepath = Format.sprintf "%s/%s" path file.name in
  try
    Bos.OS.File.write (Fpath.of_string filepath |> Result.get_ok) content
    |> Result.get_ok;
    print_endline (Format.sprintf "Wrote file '%s'" filepath)
  with
  | _ ->
    let msg = Format.sprintf "Failed to write file '%s'" filepath in
    print_endline msg;
    failwith msg
;;

let write_in_context (context : string) (files : file list) : unit =
  let root = Sihl.Configuration.root_path () |> Option.get in
  let context_path = Format.sprintf "%s/app/context/%s" root context in
  match Bos.OS.Dir.exists (Fpath.of_string context_path |> Result.get_ok) with
  | Ok true ->
    failwith (Format.sprintf "Context '%s' exists already" context_path)
  | Ok false | Error _ ->
    Bos.OS.Dir.create (Fpath.of_string context_path |> Result.get_ok) |> ignore;
    List.iter ~f:(fun file -> write_file file context_path) files
;;
