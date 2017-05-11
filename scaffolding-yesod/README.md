# Yesod Scaffolding

The Yesod scaffolding automatically builds and runs a [Yesod](http://www.yesodweb.com/book) project using [Stack](https://docs.haskellstack.org/en/stable/README/) project.

This is a minimal scaffolding which builds a defaultYesod app and runs it but doesn't help with setting up database.

## Getting Started with Scaffolding

See https://www.habitat.sh/docs/concepts-scaffolding/ to learn how to get started with Scaffolding.

## Quickstart using Yesod Scaffolding

Navigate to the directory at the root of your app and create a `habitat/` directory:

Create minimal `plan.sh`:


```sh
pkg_name=MY_APP
pkg_origin=MY_ORIGIN
pkg_version=MY_VERSION
pkg_scaffolding="dmp1ce/scaffolding-yesod"

# Set executable name (default $pkg_name)
# pkg_svc_run="$pkg_name"
```

Create minimal `default.toml`:


```
[app]
port=3000
```

Also, set your database settings in `config/settings.yml`. If you are using SQLite then set `database` to `database: "_env:SQLITE_DATABASE:var/my-project.sqlite3"` because SQLite doesn't have write access to the root directory of the running application.
