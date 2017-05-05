pkg_name=scaffolding-haskell
pkg_description="Scaffolding for Haskell Stack Applications"
pkg_origin=dmp1ce
pkg_maintainer="David Parrish <daveparrish@tutanota.com>"
pkg_version="0.1.0"
pkg_license=('Unlicense')
pkg_source=no-thanks
pkg_upstream_url="https://github.com/dmp1ce/habitat-dmp1ce"
pkg_deps=(
  ${pkg_deps[@]}
  dmp1ce/stack
)
pkg_scaffolding=core/scaffolding-base
