pkg_name=scaffolding-drupal
pkg_description="Scaffolding for Drupal Applications"
pkg_origin=dmp1ce
pkg_maintainer="David Parrish <daveparrish@tutanota.com>"
pkg_version="0.1.0"
pkg_license=('Unlicense')
pkg_upstream_url="https://github.com/dmp1ce/habitat-dmp1ce"
pkg_scaffolding=core/scaffolding-base

do_install() {
  do_default_install

  install -vd "${pkg_prefix}/lib/config" "${pkg_prefix}/lib/hooks"
  install -v -Dm644 lib/config/* "${pkg_prefix}/lib/config"
  install -v -Dm644 lib/hooks/* "${pkg_prefix}/lib/hooks" 
  install -v -Dm644 lib/default.toml "${pkg_prefix}/lib" 
}
