# Build/download project dependencies
#scaffolding_build_dependencies () {
#  stack build --only-dependencies
#}
_scaffolding_begin() {
  pkg_deps=(
    ${pkg_deps[@]}
    dmp1ce/stack
  )
}

do_default_build() {
  pwd
  ls
#  export SYSTEM_CERTIFICATE_PATH="$(pkg_path_for core/cacerts)/ssl"
  #export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(pkg_path_for core/libiconv)/lib:$(pkg_path_for core/gcc)/lib"
  echo "Scaffolding build"

  stack --local-bin-path=bin build --copy-bins yesod-bin cabal-install
  stack --local-bin-path=bin build --copy-bins
}
