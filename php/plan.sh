pkg_name=php
pkg_origin=dmp1ce
pkg_version=7.1.3
pkg_maintainer="David Parrish <daveparrish@tutanota.com>"
pkg_license=('PHP-3.01')
pkg_upstream_url=http://php.net/
pkg_description="PHP packaged with Apache Webserver module"
pkg_source=https://php.net/get/${pkg_name}-${pkg_version}.tar.bz2/from/this/mirror
pkg_filename=${pkg_name}-${pkg_version}.tar.bz2
pkg_shasum=c145924d91b7a253eccc31f8d22f15b61589cd24d78105e56240c1bb6413b94f
pkg_deps=(
  core/coreutils
  core/curl
  core/glibc
  core/libxml2
  core/libjpeg-turbo
  core/libpng
  core/openssl
  core/zlib
  dmp1ce/httpd
)
pkg_build_deps=(
  core/bison2
  core/gcc
  core/make
  core/re2c
)
pkg_bin_dirs=(bin sbin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)
pkg_interpreters=(bin/php)

do_build() {
  ./configure --prefix="$pkg_prefix" \
    --enable-exif \
    --enable-mbstring \
    --enable-opcache \
    --with-mysql=mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-curl="$(pkg_path_for curl)" \
    --with-gd \
    --with-jpeg-dir="$(pkg_path_for libjpeg-turbo)" \
    --with-libxml-dir="$(pkg_path_for libxml2)" \
    --with-openssl="$(pkg_path_for openssl)" \
    --with-png-dir="$(pkg_path_for libpng)" \
    --with-xmlrpc \
    --with-zlib="$(pkg_path_for zlib)" \
    --with-apxs2="$(pkg_path_for httpd)/bin/apxs"
  make
}

do_install() {
  do_default_install

  # Copy reference php.ini files
  install -Dv -m644 "php.ini-production" "${pkg_prefix}"
  install -Dv -m644 "php.ini-development" "${pkg_prefix}"

  # Symlink php.ini for default
  ln -sf php.ini-production ${pkg_prefix}/lib/php.ini

  # The install uses apxs which puts some files in the httpd package
  # Copy httpd installed files into php
  install -Dv "$(pkg_path_for httpd)/modules/libphp7.so" \
    "${pkg_prefix}/httpd/modules/libphp7.so"
}

do_check() {
  make test
}
