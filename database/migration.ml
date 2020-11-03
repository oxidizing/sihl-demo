let create_pizza_table =
  Sihl.Migration.create_step
    ~label:"create pizza table"
    {sql|
CREATE TABLE IF NOT EXISTS pizza (
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

let pizza = Sihl.Migration.(empty "pizza" |> add_step create_pizza_table)
let all = [ pizza ]
