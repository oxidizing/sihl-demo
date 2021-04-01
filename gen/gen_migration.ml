let template =
  {|
let create_{{name}}_table =
  Sihl.Database.Migration.create_step
    ~label:"create pizzas table"
    {sql|
     CREATE TABLE IF NOT EXISTS pizzas (
       id serial,
       name VARCHAR(128) NOT NULL,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     PRIMARY KEY (id),
     UNIQUE (name)
     );
     |sql}
;;

let create_ingredients_table =
  Sihl.Database.Migration.create_step
    ~label:"create ingredients table"
    {sql|
     CREATE TABLE IF NOT EXISTS ingredients (
       id serial,
       name VARCHAR(128) NOT NULL,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     PRIMARY KEY (id),
     UNIQUE (name)
     );
     |sql}
;;

let migration =
  Sihl.Database.Migration.(
    empty "{{name}}s"
    |> add_step create_{{name}}s_table)
;;

|}
;;
