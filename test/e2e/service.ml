(* Kernel Services *)
module Database = Sihl.Service.Database
module Repository = Sihl.Service.Repository

(* Repositories *)
module MigrationRepo = Sihl.Service.Migration_repo.PostgreSql

(* Services *)
module Migration = Sihl.Service.Migration.Make (MigrationRepo)
module Http = Sihl.Service.Http
