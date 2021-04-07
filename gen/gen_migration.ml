let template =
  {|
let create_{{name}}s_table =
  Sihl.Database.Migration.create_step
    ~label:"create {{name}}s table"
    {sql|
     CREATE TABLE IF NOT EXISTS {{name}}s (
       id serial,
       uuid UUID NOT NULL,
       {{schema}},
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     PRIMARY KEY (id),
     UNIQUE (uuid)
     );
     |sql}
;;

let migration =
  Sihl.Database.Migration.(
    empty "{{name}}"
    |> add_step create_{{name}}s_table)
;;

let all = [ migration ]

|}
;;

let postgresql_type_of_gen_type (t : Gen_core.gen_type) : string =
  let open Gen_core in
  match t with
  | Float -> "DECIMAL NOT NULL"
  | Int -> "INTEGER NOT NULL"
  | Bool -> "BOOL"
  | String -> "VARCHAR(128) NOT NULL"
  | Datetime -> "TIMESTAMP"
;;

let migration_schema (schema : Gen_core.schema) =
  schema
  |> List.map ~f:(fun (name, type_) ->
         Format.sprintf "%s %s" name (postgresql_type_of_gen_type type_))
  |> String.concat ~sep:",\n"
;;

let write_migration_file (name : string) (schema : Gen_core.schema) =
  let file =
    Gen_core.
      { name = Format.sprintf "%s.ml" name
      ; template
      ; params = [ "name", name; "schema", migration_schema schema ]
      }
  in
  Gen_core.write_in_database file
;;
