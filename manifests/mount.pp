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
# [*dir_host*]
#     Provide an host to where metadata and storage nodes will be connecting, defaults: <tt>$::fqdn</tt>
# [*dir_port*]
#     (Optional) A port for directory service connection
# [*dir_protocol*]
#     (Optional) A protocol for directory service connection
# [*atboot*]
#     Should this mount be active also at boot time? If +true+, it will be added to system +/etc/fstab+
# [*options*]
#     Mount options for the mounts, as they would appear in the fstab.
#
define xtreemfs::mount (
  $volume,
  $mountpoint   = $name,
  $ensure       = 'mounted',
  $dir_host     = undef,
  $dir_port     = undef,
  $dir_protocol = undef,
  $atboot       = false,
  $options      = 'defaults,allow_other',
) {
  include xtreemfs::internal::packages::client
  include xtreemfs::internal::workflow
  include xtreemfs::settings

  validate_string($options)

  $host = directory_address($dir_host, $dir_port, $dir_protocol, $xtreemfs::settings::dir_service)

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