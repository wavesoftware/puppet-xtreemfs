# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::configure::directory (
  $extra,
) {
  include xtreemfs::internal::workflow

  $changes = extra_to_augeas($extra, [])

  $configfile = '/etc/xos/xtreemfs/dirconfig.properties'
  augeas { 'xtreemfs::configure::directory':
    context => "/files${configfile}",
    changes => $changes,
    incl    => $configfile,
    lens    => 'Properties.lns',
    require => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$xtreemfs::internal::workflow::configure],
  }
}