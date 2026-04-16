# postgres
Postges is 30 year old project that is really awesome, but also rough around the edges.  The underlying technology is modern despite legacy hertiage and being filled with overloaded terms.

# terms
* Postgres is the protocol & underlying technology.
* When you 'connect to a database', you are first connecting to the DBMS and then the database inside.

Sometimes it's hard to just be clear.  Here's how I'll be using the language going forward.

| FullName                  | Shorthand | Description                                  |
|---------------------------|-----------|----------------------------------------------|
| DatabaseManagementSystem  | DBMS      | Postgres Instance                            |
| Database                  | DB        | Database inside of the DBMS                  |
| PostgresSchema            | Schema    | Postgres Schema inside of the DB             |
| Tables/Sequences/Etc      | n/a       | Objects that live inside of Postgres' schema |

# responsibitilies
I'm all for shift left, where developers are responsible for everything and allow their applications to do anything.  The way of limiting their blast radius is giving each application their own DBMS--where they also become responsible for backups, monitoring, pooling, etc...

However if they can adhere to a few constraints, they can use a shared DBMS that's already maintained.  That constraint is doing everything as a DB owner.  DB owners can do pretty much anything inside of that database... They can create schemas, manage indexes, and even drop tables.  However they cannot install extensions.  Extensions require DBMS level permissions to make extension binaries available to the instance and are able to be installed into schemas.  That installation requires DBMS super admin and also the schema has to already exist.

So there can be a bit of back and forth between who should be responsible for schemas.  Developers need to create the schema then operators need to come back and install the extension.

I argue that schema creation/management should be on the operator.  But the application/developer is responsible for describing everything they need upfront.  That schema can be created when the database is initialized and extensions installed before an application starts. In 95% of cases, only one schema is needed and that one schema name should not matter. So that's why I would prefer to just rely upon the database's search_path setting.

# postgres operators
Zalando's Postgres Operator follows the approach of making it easy to do multi-tenant postgres clusters and default opinionation makes it easy for handle DBMS/DB/Schema lifecycles with full RBAC support.

CNPG takes a largely 'shift left' approach of DBMS per application and encouraging imperative cluster management.  That is slowly shifting as they add more resources to do declarative management--however it is still a work in progress.

https://github.com/cloudnative-pg/cloudnative-pg/issues/3242#issuecomment-2965932570

## cnpg
### cluster
by default bootstrap.initdb will always run with a database/owner named app.  They are working on retiring that and moving to their database custom resource.
```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgresql
  namespace: sandbox
spec:
  instances: 2
  imageName: ghcr.io/cloudnative-pg/postgresql:17.5
  # creates a database/role by default
  # convention over configuration paradigm
  # https://cloudnative-pg.io/docs/1.29/bootstrap#bootstrap-an-empty-cluster-initdb
  bootstrap:
    # initdb is default, other options include recovery/backup
    initdb:
      database: app1
      owner: app1
      # run sql queries
      # https://cloudnative-pg.io/docs/1.29/bootstrap#executing-queries-after-initialization
      # runs as application owner
      postInitTemplateSQL:
        - DROP SCHEMA public;
      postInitApplicationSQL:
        - CREATE SCHEMA IF NOT EXISTS data AUTHORIZATION app1;
        - ALTER DATABASE app1 SET search_path TO "$user", data;
  storage:
    size: 5Gi
  resources:
    requests:
      memory: 10Mi
      cpu: 10m
  managed:
    services:
      additional:
        - selectorType: rw
          serviceTemplate:
            metadata:
              name: postgresql-kftray
              annotations:
                kftray.app/enabled: "true"
                kftray.app/configs: "postgresql-5432-5432"
            spec:
              type: ClusterIP
```

### database
Database largely works, however its missing several capabilities.
* there is no way to do postInitApplicationSQL or any other imperative actions
* by default the schema defaults to public, even when not in the explicit schemas list.
* unable to manage database parameters for search_path.  Defaults to "$user, public".
```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: postgresql-app2
  namespace: sandbox
spec:
  databaseReclaimPolicy: retain # retain or delete
  ensure: present # present or absent
  name: app2
  # expects this role to be created manually
  # need to also see if i can have 
  owner: app1
  schemas:
    - name: data
      owner: app1
  cluster:
    name: postgresql
```