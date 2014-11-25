# == Manages an volume on directory service
#
# You can create and destroy volumes on local and external storages
#
# === Parameters:
#
# [*name*]
#     A name of volume, can be any valid alphanumeric string. Must be unique in dierectory service
# [*ensure*]
#     Standard ensure property. Can be: +present+ or +absent+
# [*dir_service*]
#     A hostname of directory service
# [*options*]
#     An extra options that will be passed to +mkfs.xtreemfs+ command. Use +mkfs.xtreemfs --help+ to see all possible options.
#
define xtreemfs::volume (
  $ensure      = 'present',
  $dir_service = $::xtreemfs::settings::dir_service,
  $options     = {},
) {
  include xtreemfs::internal::packages::client
  include xtreemfs::internal::workflow

  xtreemfs_volume { $name:
  	ensure  => $ensure,
  	host    => $dir_service,
  	options => $options,
  	require => Anchor[$xtreemfs::internal::workflow::service],
  }
}