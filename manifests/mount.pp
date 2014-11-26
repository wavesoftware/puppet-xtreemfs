# == Manages an mount of XtreemFS volume
#
# You can create and destroy mount points for XtreemFS volumes. By default it will also add an entry to system fstab, so that mount point will be active at boot time.
#
# === Parameters:
#
# [*mountpoint*]
#     (namevar) A directory to became a mount point
# [*volume*]
#     A name of volume that is active in directory service
# [*ensure*]
#     Standard ensure property. Can be: +mounted+, +unmounted+ (same as +present+) or +absent+
# [*dir_service*]
#     A hostname of directory service
# [*atboot*]
#     Should this mount be active also at boot time? If +true+, it will be added to system +/etc/fstab+
# [*options*]
#     Mount options for the mounts, as they would appear in the fstab.
#
define xtreemfs::mount (
  $volume,
  $mountpoint  = $name,
  $ensure      = 'mounted',
  $dir_service = undef,
  $atboot      = true,
  $options     = 'defaults,allow_other',
) {
  include xtreemfs::internal::packages::client
  include xtreemfs::internal::workflow
  include xtreemfs::settings

  validate_string($options)

  $host = $dir_service ? {
    undef   => $xtreemfs::settings::dir_service,
    default => $dir_service,
  }

  if defined(Xtreemfs::Volume[$volume]) {
    if $ensure == 'present' or $ensure == 'mounted' {
      Xtreemfs::Volume[$volume] -> Mount[$name]
    } else {
      Mount[$name] -> Xtreemfs::Volume[$volume]
    }
  }

  if ! defined(File[$mountpoint]) {
    file { $mountpoint:
      ensure => 'directory',
      before => Mount[$mountpoint],
    }
  }

  mount { $mountpoint:
    ensure  => $ensure,
    atboot  => $atboot,
    device  => "${host}/${volume}",
    fstype  => 'xtreemfs',
    options => $options,
    require => Anchor[$xtreemfs::internal::workflow::service],
  }
}