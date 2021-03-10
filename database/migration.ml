(* Put your database migrations here. *)

let create_pizzas_table =
  Sihl.Database.Migration.create_step
    ~label:"create pizzas table"
    {sql|
     CREATE TABLE IF NOT EXISTS pizzas (
       id serial,
       uuid uuid NOT NULL,
       name VARCHAR(128) NOT NULL,
       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
     PRIMARY KEY (id),
     UNIQUE (uuid),
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
       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
     PRIMARY KEY (id),
     UNIQUE (name)
     );
     |sql}
;;

let create_pizzas_ingredients_table =
  Sihl.Database.Migration.create_step
    ~label:"create pizzas_ingredients table"
    {sql|
     CREATE TABLE IF NOT EXISTS pizzas_ingredients (
       pizza_id INTEGER NOT NULL,
       ingredient_id INTEGER NOT NULL,
       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
     UNIQUE (pizza_id, ingredient_id)
     );
     |sql}
;;

let pizzas =
  Sihl.Database.Migration.(
    empty "pizzas"
    |> add_step create_pizzas_table
    |> add_step create_ingredients_table
    |> add_step create_pizzas_ingredients_table)
;;

let all = [ pizzas ]
