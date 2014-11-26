# == Manages an volume on directory service
#
# You can create and destroy volumes on local and external storages
#
# === Parameters:
#
# [*volume*]
#     (namevar) A name of volume, can be any valid alphanumeric string. Must be unique in directory service
# [*ensure*]
#     Standard ensure property. Can be: +present+ or +absent+
# [*dir_service*]
#     A hostname of directory service
# [*options*]
#     An extra options that will be passed to +mkfs.xtreemfs+ command. Use +mkfs.xtreemfs --help+ to see all possible options.
#
define xtreemfs::volume (
  $volume      = $name,
  $ensure      = 'present',
  $dir_service = undef,
  $options     = {},
) {
  include xtreemfs::internal::packages::client
  include xtreemfs::internal::workflow
  include xtreemfs::settings

  validate_hash($options)

  $host = $dir_service ? {
    undef   => $xtreemfs::settings::dir_service,
    default => $dir_service,
  }

  xtreemfs_volume { $volume:
    ensure  => $ensure,
    host    => $host,
    options => $options,
    require => Anchor[$xtreemfs::internal::workflow::service],
  }
}