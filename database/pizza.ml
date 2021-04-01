(* Put your database migrations here. *)

let create_pizzas_table =
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

let create_pizzas_ingredients_table =
  Sihl.Database.Migration.create_step
    ~label:"create pizzas_ingredients table"
    {sql|
     CREATE TABLE IF NOT EXISTS pizzas_ingredients (
       pizza_id INTEGER NOT NULL,
       ingredient_id INTEGER NOT NULL,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     UNIQUE (pizza_id, ingredient_id),
     CONSTRAINT fk_pizza
       FOREIGN KEY (pizza_id) REFERENCES pizzas (id)
       ON DELETE CASCADE,
     CONSTRAINT fk_ingredient
       FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
     );
     |sql}
;;

let add_vegan_flag_and_price =
  Sihl.Database.Migration.create_step
    ~label:"add vegan flag and price"
    {sql|
     ALTER TABLE ingredients
       ADD COLUMN is_vegan BOOL NOT NULL DEFAULT false,
       ADD COLUMN price INT NOT NULL DEFAULT 0;
     |sql}
;;

let remove_timezone_pizzas_table =
  Sihl.Database.Migration.create_step
    ~label:"remove timezone information from pizzas"
    {sql|
      ALTER TABLE pizzas
        ALTER COLUMN created_at TYPE TIMESTAMP,
        ALTER COLUMN updated_at TYPE TIMESTAMP;
    |sql}
;;

let remove_timezone_ingredients_table =
  Sihl.Database.Migration.create_step
    ~label:"remove timezone information from ingredients"
    {sql|
      ALTER TABLE ingredients
        ALTER COLUMN created_at TYPE TIMESTAMP,
        ALTER COLUMN updated_at TYPE TIMESTAMP;
    |sql}
;;

let remove_timezone_pizzas_ingredients_table =
  Sihl.Database.Migration.create_step
    ~label:"remove timezone information from pizzas_ingredients"
    {sql|
      ALTER TABLE pizzas_ingredients
        ALTER COLUMN created_at TYPE TIMESTAMP,
        ALTER COLUMN updated_at TYPE TIMESTAMP;
    |sql}
;;

let pizzas =
  Sihl.Database.Migration.(
    empty "pizzas"
    |> add_step create_pizzas_table
    |> add_step create_ingredients_table
    |> add_step create_pizzas_ingredients_table
    |> add_step add_vegan_flag_and_price
    |> add_step remove_timezone_pizzas_table
    |> add_step remove_timezone_ingredients_table
    |> add_step remove_timezone_pizzas_ingredients_table)
;;

let all = [ pizzas ]
