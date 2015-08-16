# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::configure::directory (
  $properties,
  $port = 32638,
) {
  include xtreemfs::internal::workflow
  include xtreemfs::internal::configure::augeas::verify
  $merged  = merge({
    'listen.port' => $port
  }, $properties)
  $changes = properties_to_augeas($merged, [])
  $anchor  = 'xtreemfs::internal::configure::directory'

  $configfile = '/etc/xos/xtreemfs/dirconfig.properties'
  augeas { 'xtreemfs::configure::directory':
    context => "/files${configfile}",
    changes => $changes,
    incl    => $configfile,
    lens    => 'Properties.lns',
    require => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$anchor],
  }
  
  anchor { $anchor:
    notify => Anchor[$xtreemfs::internal::workflow::configure],
  }
}