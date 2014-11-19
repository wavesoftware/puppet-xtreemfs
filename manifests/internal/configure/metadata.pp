# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::configure::metadata (
  $dir_service,
  $extra,
) {
  include xtreemfs::internal::workflow
  
  $this_changes = ["set dir_service.host ${dir_service}"]
  $changes = extra_to_augeas($extra, $this_changes)

  $configfile = '/etc/xos/xtreemfs/mrcconfig.properties'
  augeas { 'xtreemfs::configure::mrc':
    context => "/files${configfile}",
    changes => $changes,
    incl    => $configfile,
    lens    => 'Properties.lns',
    require => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$xtreemfs::internal::workflow::configure],
  }
}