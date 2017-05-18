pkg_deps=(
  dmp1ce/php
  dmp1ce/httpd
  core/sqlite
  ${pkg_deps[@]}
)
pkg_build_deps=(
  dmp1ce/composer
  core/tar
  ${pkg_build_deps[@]}
)

scaffolding_load() {
  _setup_vars
  #_update_pkg_build_deps
  _update_svc_run
  _update_svc_user
}

do_default_build() {
  scaffolding_composer_install
}

scaffolding_composer_install() {
  # Keep it simple until there is a known problem with simple install
  # over the top of current source directory
  composer install --no-dev
}

do_default_install() {
  # Copy Drupal installation
  scaffolding_install_app

  # Remove development files
  rm -rfv "${scaffolding_app_prefix}/web/sites/default/files/"

  # Create symlink for /files
  ln -sfv "${pkg_svc_data_path}/files" "${scaffolding_app_prefix}/web/sites/default/files"

  # Create symlink for settings.php
  ln -sfv "${pkg_svc_data_path}/settings.php" "${scaffolding_app_prefix}/web/sites/default/settings.php"
  
  # Symlink php.ini
  ln -sfv "$(pkg_path_for dmp1ce/php)/php.ini-production" "${pkg_prefix}/"

  # Setup ServerRoot for httpd
  install -dv ${pkg_prefix}/httpd
  ln -sfv $(pkg_path_for dmp1ce/httpd)/bin ${pkg_prefix}/httpd/bin
  ln -sfv $(pkg_path_for dmp1ce/httpd)/conf ${pkg_prefix}/httpd/conf
  ln -sfv $(pkg_path_for dmp1ce/httpd)/error ${pkg_prefix}/httpd/error
  ln -sfv $(pkg_path_for dmp1ce/httpd)/icons ${pkg_prefix}/httpd/icons
  install -v -d ${pkg_prefix}/httpd/modules
  ln -sfv $(pkg_path_for dmp1ce/httpd)/modules/* ${pkg_prefix}/httpd/modules/
  # Get Apache php module from php package
  ln -sfv $(pkg_path_for dmp1ce/php)/httpd/modules/libphp7.so ${pkg_prefix}/httpd/modules/mod_php7.so

  # Symlink httpd configuration files
  ln -sfv $(pkg_path_for dmp1ce/httpd) ${pkg_prefix}/httpd

  # Copy config, hooks and default.toml
  # TODO: Ignore install if files already exist
  install -v -d "${pkg_prefix}/config" "${pkg_prefix}/hooks"
  install -v -Dm644 "$(pkg_path_for scaffolding-drupal)/lib/config"/* "${pkg_prefix}/config"
  install -v -Dm644 "$(pkg_path_for scaffolding-drupal)/lib/hooks"/* "${pkg_prefix}/hooks"
  install -v -Dm644 "$(pkg_path_for scaffolding-drupal)/lib/default.toml" "${pkg_prefix}"
}

scaffolding_install_app() {
  build_line "Installing app codebase to $scaffolding_app_prefix"
  mkdir -pv "$scaffolding_app_prefix"

  # Use find to enumerate all files and directories for copying.
  find . | _tar_pipe_app_cp_to "$scaffolding_app_prefix"
}

_update_svc_run() {
  if [[ -z "$pkg_svc_run" ]]; then
    pkg_svc_run="httpd -DFOREGROUND -f $pkg_svc_config_path/httpd.conf"
    build_line "Setting pkg_svc_run='$pkg_svc_run'"
  fi
}

_update_svc_user() {
  # TODO: Only set as root for binding to ports lower than 1024
  if [[ "$pkg_svc_user" == "hab" ]]; then
    pkg_svc_user="root"
    build_line "Setting pkg_svc_user='$pkg_svc_user'"
  fi
}

_setup_vars() {
  # The install prefix path for the app
  scaffolding_app_prefix="$pkg_prefix/app"
}

  
# **Internal** Use a "tar pipe" to copy the app source into a destination
# directory. This function reads from `stdin` for its file/directory manifest
# where each entry is on its own line ending in a newline. Several filters and
# changes are made via this copy strategy:
#
# * All user and group ids are mapped to root/0
# * No extended attributes are copied
# * Some file editor backup files are skipped
# * Some version control-related directories are skipped
# * Any `./habitat/` directory is skipped
# * Any `./vendor/bundle` directory is skipped as it may have native gems
_tar_pipe_app_cp_to() {
  local dst_path tar
  dst_path="$1"
  tar="$(pkg_path_for tar)/bin/tar"
  "$tar" -cp \
      --owner=root:0 \
      --group=root:0 \
      --no-xattrs \
      --exclude-backups \
      --exclude-vcs \
      --exclude='habitat' \
      --exclude='results' \
      --files-from=- \
      -f - \
  | "$tar" -x \
      -C "$dst_path" \
      -f -
}

do_default_strip() {
  return 0
}

#_update_pkg_build_deps() {
#  # Order here is important--entries which should be first in
#  # `${pkg_build_deps[@]}` should be called last.
#
#  _detect_git
#}
#
#_detect_git() {
#  if [[ -d ".git" ]]; then
#    build_line "Detected '.git' directory, adding git packages as build deps"
#    pkg_build_deps=(core/git ${pkg_build_deps[@]})
#    debug "Updating pkg_build_deps=(${pkg_build_deps[*]}) from Scaffolding detection"
#    _uses_git=true
#  fi
#}
