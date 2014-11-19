# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::configure::storage (
  $dir_service,
  $object_dir,
  $extra,
) {
  include xtreemfs::internal::workflow

  $this_changes = [
    "set dir_service.host ${dir_service}",
    "set object_dir ${object_dir}/objs",
  ]
  $changes = extra_to_augeas($extra, $this_changes)

  $configfile = '/etc/xos/xtreemfs/osdconfig.properties'
  augeas { 'xtreemfs::configure::osd':
    context => "/files${configfile}",
    changes => $changes,
    incl    => $configfile,
    lens    => 'Properties.lns',
    require => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$xtreemfs::internal::workflow::configure],
  }
  
  file { $object_dir:
    ensure  => 'directory',
    owner   => 'xtreemfs',
    group   => 'xtreemfs',
    require => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$xtreemfs::internal::workflow::configure],
  }
}