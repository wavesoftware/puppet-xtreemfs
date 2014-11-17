# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::configure::storage (
  $dir_service,
  $object_dir,
) {
  include xtreemfs::internal::workflow
  augeas { 'xtreemfs::configure::osd':
    context => '/files/etc/xos/xtreemfs/osdconfig.properties',
    changes => [
      "set dir_service.host ${dir_service}",
      "set object_dir ${object_dir}/objs",
    ],
    before  => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$xtreemfs::internal::workflow::configure],
  }
  
  file { $object_dir:
    ensure => 'directory',
    owner  => 'xtreemfs',
    group  => 'xtreemfs',
    before  => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$xtreemfs::internal::workflow::configure],
  }
}