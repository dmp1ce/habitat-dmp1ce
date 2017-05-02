# This package has the following issues:
#   - Requires system GHC (Cannot download GHC during 'stack setup')
#     https://github.com/commercialhaskell/stack/issues/3144
#   - Build must symlink to /etc/protocol
#   - Stack downloads several dependencies into '$HAB_CACHE_SRC_PATH/.stack'
pkg_name=stack
pkg_origin=dmp1ce
pkg_version="1.4.0"
pkg_maintainer="David Parrish <daveparrish@tutanota.com>"
pkg_license=('BSD-3-Clause')
pkg_source="https://github.com/commercialhaskell/${pkg_name}/archive/v${pkg_version}.tar.gz"
pkg_filename="v${pkg_version}.tar.gz"
pkg_dirname="${pkg_name}-${pkg_version}"
pkg_shasum="595d311ad117e41ad908b7065743917542b40f343d1334673e98171ee74d36e6"

pkg_deps=(
  core/git
  core/gnupg
  core/xz
  core/zlib
  core/cacerts
  core/tar
  core/libiconv
  core/gmp
  core/libffi
  core/gcc
  dmp1ce/ghc
  core/iana-etc
)

pkg_build_deps=(
  core/make
  dmp1ce/stack
)

pkg_bin_dirs=(bin)
pkg_description="The Haskell Tool Stack"
pkg_upstream_url="https://docs.haskellstack.org/en/stable/README/"

_stack_root="$HAB_CACHE_SRC_PATH/stack-root"
do_clean() {
  do_default_clean

  # Remove files that could have also been created during the last build.
  rm -fv /etc/protocol
  rm -rfv ${_stack_root}
}

do_build() {
  export SYSTEM_CERTIFICATE_PATH="$(pkg_path_for core/cacerts)/ssl"
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(pkg_path_for core/libiconv)/lib:$(pkg_path_for core/gcc)/lib"
  # Require /etc/protocols for tcp service
  ln -sfv $(pkg_path_for core/iana-etc)/etc/protocols /etc
  stack --stack-root=${_stack_root} --system-ghc --stack-yaml=stack-8.0.yaml setup
  stack --stack-root="${_stack_root}" --extra-include-dirs="$(pkg_path_for core/zlib)/include" \
    --extra-lib-dirs="$(pkg_path_for core/zlib)/lib" --system-ghc --stack-yaml=stack-8.0.yaml build
}

do_check() {
  export SYSTEM_CERTIFICATE_PATH="$(pkg_path_for core/cacerts)/ssl"
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(pkg_path_for core/libiconv)/lib:$(pkg_path_for core/gcc)/lib"
  stack --stack-root="${_stack_root}" --extra-include-dirs="$(pkg_path_for core/zlib)/include" \
    --extra-lib-dirs="$(pkg_path_for core/zlib)/lib" --system-ghc --stack-yaml=stack-8.0.yaml test
}

do_install() {
  # --copy-bins only copies stack into /root directory.
  # Issue here: https://github.com/commercialhaskell/stack/issues/848
  # Instead find stack and copy to bin
  find .stack-work/install/x86_64-linux/ -name stack \
    -exec sh -c 'file -i "$1" | grep -q "x-executable; charset=binary"' _ {} \; \
    -print \
    -exec install -D {} ${pkg_prefix}/bin/stack \;
}
