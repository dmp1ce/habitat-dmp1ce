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
  dmp1ce/ghc
)

pkg_build_deps=(
  core/make
  dmp1ce/stack
)

pkg_bin_dirs=(bin)
pkg_description="The Haskell Tool Stack"
pkg_upstream_url="https://docs.haskellstack.org/en/stable/README/"

do_build() {
  export SYSTEM_CERTIFICATE_PATH="$(pkg_path_for core/cacerts)/ssl"
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(pkg_path_for core/libiconv)/lib"
  stack --system-ghc --stack-yaml=stack-8.0.yaml setup
  stack --extra-include-dirs=$(pkg_path_for core/zlib)/include --extra-lib-dirs=$(pkg_path_for core/zlib)/lib --system-ghc --stack-yaml=stack-8.0.yaml build
}

do_check() {
  export SYSTEM_CERTIFICATE_PATH="$(pkg_path_for core/cacerts)/ssl"
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(pkg_path_for core/libiconv)/lib"
  stack --extra-include-dirs=$(pkg_path_for core/zlib)/include --extra-lib-dirs=$(pkg_path_for core/zlib)/lib --system-ghc test
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
