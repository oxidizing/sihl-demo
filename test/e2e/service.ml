(* Kernel Services *)
module Database = Sihl.Database.Service
module Repository = Sihl.Repository.Service

(* Repositories *)
module MigrationRepo = Sihl.Migration.Service.Repo.MakePostgreSql (Database)

(* Services *)
module Migration = Sihl.Migration.Service.Make (MigrationRepo)
module Http = Sihl.Http.Service
