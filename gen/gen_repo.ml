let template =
  {|
let clean_request =
  Caqti_request.exec Caqti_type.unit "TRUNCATE TABLE {{table_name}} CASCADE;"
;;

let clean () =
  let open Lwt_result.Syntax in
  Sihl.Database.query' (fun (module Connection : Caqti_lwt.CONNECTION) ->
      Connection.exec clean_request ())
;;

let insert_request =
  Caqti_request.exec
    {{caqti_type}}
    {sql|
        INSERT INTO {{table_name}} (
          uuid,
          {{fields}},
          created_at,
          updated_at
        ) VALUES (
          $?,
          {{parameters}},
          $?,
          $?
        )
        |sql}
;;

let insert ({{name}} : Model.t) =
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.exec
        insert_request
        {{caqti_value}})
;;

let update_request =
  Caqti_request.exec
    {{caqti_type}}
    {sql|
        UPDATE {{table_name}} SET
          {{update_fields}},
          created_at = $4,
          updated_at = $5
        WHERE uuid = $1;
        |sql}
;;

let update ({{name}} : Model.t) =
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.exec
        update_request
        {{caqti_value}})
;;

let find_request =
  Caqti_request.find_opt
    Caqti_type.string
    {{caqti_type}}
    {sql|
        SELECT
          uuid,
          {{fields}},
          created_at,
          updated_at
        FROM {{table_name}}
        WHERE name = ?
        |sql}
;;

let find (id : string) : Model.t option Lwt.t =
  let open Lwt.Syntax in
  let* {{name}} =
    Sihl.Database.query' (fun connection ->
        let module Connection = (val connection : Caqti_lwt.CONNECTION) in
        Connection.find_opt find_request id)
  in
  Lwt.return
  @@ Option.map
       (fun {{destructured_fields}} ->
         Model.{ id; {{created_value}} created_at; updated_at })
       {{name}}
;;

let find_all_request =
  Caqti_request.collect
    Caqti_type.unit
    {{caqti_type}}
    {sql|
        SELECT
          uuid,
          {{fields}},
          created_at,
          updated_at
        FROM {{table_name}}
        ORDER BY id DESC
        |sql}
;;

let find_all () : Model.t list Lwt.t =
  let open Lwt.Syntax in
  let* {{name}}s =
    Sihl.Database.query' (fun connection ->
        let module Connection = (val connection : Caqti_lwt.CONNECTION) in
        Connection.collect_list find_all_request ())
  in
  Lwt.return
  @@ List.map
       ~f:(fun {{destructured_fields}} ->
         Model.{ id; {{created_value}} created_at; updated_at })
       {{name}}s
;;

let delete_request =
  Caqti_request.exec
    Caqti_type.string
    {sql|
        DELETE FROM {{table_name}}
        WHERE name = ?
        |sql}
;;

let delete ({{name}} : Model.t) : unit Lwt.t =
  Sihl.Database.query' (fun connection ->
      let module Connection = (val connection : Caqti_lwt.CONNECTION) in
      Connection.exec delete_request {{name}}.Model.id)
;;
|}
;;

let caqti_type (schema : Gen_core.schema) =
  (* TODO [jerben] add id, created_at and updated_at *)
  let rec loop = function
    | [ el1; el2 ] ->
      let el1 = Gen_core.caqti_type_of_gen_type el1 in
      let el2 = Gen_core.caqti_type_of_gen_type el2 in
      Format.sprintf "(tup2 %s %s)" el1 el2
    | el1 :: rest ->
      let el1 = Gen_core.caqti_type_of_gen_type el1 in
      Format.sprintf "(tup2 %s %s)" el1 (loop rest)
    | [] -> failwith "Empty schema provided"
  in
  let types = schema |> List.map ~f:snd |> loop in
  Format.sprintf "Caqti_type.%s" types
;;

let caqti_value name (schema : Gen_core.schema) =
  (* TODO [jerben] add id, created_at and updated_at *)
  let rec loop = function
    | [ el1; el2 ] ->
      let el1 = Format.sprintf "%s.Model.%s" name el1 in
      let el2 = Format.sprintf "%s.Model.%s" name el2 in
      Format.sprintf "(%s, %s)" el1 el2
    | el1 :: rest ->
      let el1 = Format.sprintf "%s.Model.%s" name el1 in
      Format.sprintf "(%s, %s)" el1 (loop rest)
    | [] -> failwith "Empty schema provided"
  in
  schema |> List.map ~f:fst |> loop
;;

let destructued_fields (schema : Gen_core.schema) =
  (* TODO [jerben] add id, created_at and updated_at *)
  let rec loop = function
    | [ el1; el2 ] -> Format.sprintf "(%s, %s)" el1 el2
    | el1 :: rest -> Format.sprintf "(%s, %s)" el1 (loop rest)
    | [] -> failwith "Empty schema provided"
  in
  schema |> List.map ~f:fst |> loop
;;

let fields (schema : Gen_core.schema) =
  schema |> List.map ~f:fst |> String.concat ~sep:", "
;;

let update_fields (schema : Gen_core.schema) =
  schema
  |> List.mapi ~f:(fun idx (name, _) -> name, idx)
  |> List.map ~f:(fun (name, idx) -> Format.sprintf "%s = $%d" name idx)
  |> String.concat ~sep:", "
;;

let parameters (schema : Gen_core.schema) =
  schema |> List.map ~f:(fun _ -> "?") |> String.concat ~sep:", "
;;

let file (name : string) (schema : Gen_core.schema) =
  let params =
    [ "name", name
    ; "table_name", Format.sprintf "%s" name
    ; "caqti_type", caqti_type schema
    ; "caqti_value", caqti_value name schema
    ; "destructured_fields", destructued_fields schema
    ; "created_value", Gen_model.created_value schema
    ; "fields", fields schema
    ; "update_fields", update_fields schema
    ; "parameters", parameters schema
    ]
  in
  Gen_core.{ name = "repo.ml"; template; params }
;;
