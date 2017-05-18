# Drupal Scaffolding

The Drupal scaffolding automatically builds and runs a [Drupal](https://www.drupal.org/) project using [Composer](https://getcomposer.org/) to build the project and [httpd](https://httpd.apache.org/) + [php](https://secure.php.net/) as the webserver.

This is a minimal scaffolding which builds a default, uninstalled Drupal website. Currently, the user needs to setup the database on their own using the Drupal installation wizard. The installation wizard should show by default on first visiting the website.

## Getting Started with Scaffolding

See https://www.habitat.sh/docs/concepts-scaffolding/ to learn how to get started with Scaffolding.

## Quickstart using Scaffolding

Navigate to the directory at the root of your app and create a `habitat/` directory:

Create minimal `plan.sh`:


```sh
pkg_name=MY_APP
pkg_origin=MY_ORIGIN
pkg_version=MY_VERSION
pkg_scaffolding="dmp1ce/scaffolding-drupal"
```

It is optional to override `default.toml`. See the default `default.toml` here in "$(pkg_path_for scaffolding-drupal)/lib/default.toml" in Habitat studio.

Visit the website and install Drupal. By default the Drupal site will be located at: `http://localhost:8080/`.
