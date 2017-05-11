scaffolding_load() {
  _setup_funcs

  _update_vars
  _update_pkg_build_deps
  _update_bin_dirs
  _update_svc_run
}

_new_do_default_clean() {
  # Skip default clean for testing purposes
  if [[ -z "$NO_CLEAN" ]]; then
    _stock_do_default_clean
  fi
}

do_default_prepare() {
  # Symlink /etc/protocols because it is needed by Stack
  # Relevant Stack issue here: https://github.com/commercialhaskell/stack/issues/2372
  ln -sf "$(pkg_path_for core/iana-etc)/etc/protocols" /etc/protocols
}

do_default_build() {
  mkdir -p "$HAB_CACHE_SRC_PATH/$pkg_dirname/stack-root"
  mkdir -p "$HAB_CACHE_SRC_PATH/$pkg_dirname/stack-work"
  ln -s "$HAB_CACHE_SRC_PATH/$pkg_dirname/stack-work" tmp-stack-work
  stack --stack-root "$HAB_CACHE_SRC_PATH/$pkg_dirname/stack-root" --work-dir "tmp-stack-work" build
  rm tmp-stack-work
}

do_default_install() {
  install -dv "${pkg_prefix}/bin"

  ln -s "$HAB_CACHE_SRC_PATH/$pkg_dirname/stack-work" tmp-stack-work
  stack --stack-root "$HAB_CACHE_SRC_PATH/$pkg_dirname/stack-root" --work-dir "tmp-stack-work" \
    --local-bin-path "${pkg_prefix}/bin" build --copy-bins
  rm tmp-stack-work

  install -dv "${pkg_prefix}/yesod-config"
  cp -Rv config/* "${pkg_prefix}/yesod-config"
  install -d "${pkg_prefix}/static"
  cp -Rv static/* "${pkg_prefix}/static"
}

# This becomes the `do_default_build_config` implementation thanks to some
# function "renaming" above. I know, right?
_new_do_default_build_config() {
  local key dir env_sh

  _stock_do_default_build_config

  if [[ ! -f "$PLAN_CONTEXT/hooks/init" ]]; then
    build_line "No user-defined init hook found, generating init hook"
    mkdir -p "$pkg_prefix/hooks"
    cat <<EOT >> "$pkg_prefix/hooks/init"
#!/bin/sh
set -e
export HOME="$pkg_svc_data_path"
# Symlink files in 'config' and 'static' directories
ln -sfv "$pkg_prefix"/yesod-config/* "$pkg_svc_config_path"
ln -sfv "$pkg_prefix"/static/* "$pkg_svc_static_path"
EOT
    chmod 755 "$pkg_prefix/hooks/init"
  fi
}

_setup_funcs() {
  # Use the stock `do_default_clean` by renaming it so we can call the stock behavior.
  _rename_function "do_default_clean" "_stock_do_default_clean"
  _rename_function "_new_do_default_clean" "do_default_clean"
  # Use the stock `do_default_build_config` by renaming it so we can call the stock behavior.
  _rename_function "do_default_build_config" "_stock_do_default_build_config"
  _rename_function "_new_do_default_build_config" "do_default_build_config"
}

do_default_check() {
  stack test
}

do_default_end() {
  # Remove /etc/protocols
  rm /etc/protocols
}

_update_vars() {
  # Export the app's listen port
  _set_if_unset pkg_exports port "app.port"
}

_update_pkg_build_deps() {
  build_line "Adding Stack and iana-etc package to build dependencies"
  pkg_build_deps=(
    dmp1ce/stack
    core/iana-etc
    ${pkg_build_deps[@]}
  )
  debug "Updating pkg_build_deps=(${pkg_deps[*]})"
}

_update_bin_dirs() {
  # Add the `bin/` directory to the bin dirs so they will be on `PATH.
  # We do this after the existing values so
  # that the Plan author's `${pkg_bin_dir[@]}` will always win.
  pkg_bin_dirs=(
    ${pkg_bin_dir[@]}
    bin
  )
}

_update_svc_run() {
  # TODO: Find exe name from Stack
  if [[ -z "$pkg_svc_run" ]]; then
    pkg_svc_run="$pkg_prefix/bin/${pkg_name}"
    build_line "Setting pkg_svc_run='$pkg_svc_run'"
  fi
}

_set_if_unset() {
  local hash key val
  hash="$1"
  key="$2"
  val="$3"
  if [[ ! -v "$hash[$key]" ]]; then
    eval "$hash[$key]='$val'"
  fi
}

# Heavily inspired from:
# https://gist.github.com/Integralist/1e2616dc0b165f0edead9bf819d23c1e
_rename_function() {
  local orig_name new_name
  orig_name="$1"
  new_name="$2"

  declare -F "$orig_name" > /dev/null \
    || exit_with "No function named $orig_name, aborting" 97
  eval "$(echo "${new_name}()"; declare -f "$orig_name" | tail -n +2)"
}
