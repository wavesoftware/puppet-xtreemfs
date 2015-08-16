# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::configure::storage (
  $dir_service,
  $object_dir,
  $properties,
  $port = 32640,
) {
  include xtreemfs::internal::workflow
  include xtreemfs::internal::configure::augeas::verify

  $this_changes = [
    "set dir_service.host ${dir_service}",
    "set object_dir ${object_dir}/objs/",
  ]
  $merged  = merge({
    'listen.port' => $port
  }, $properties)
  $changes = properties_to_augeas($merged, $this_changes)
  $anchor  = 'xtreemfs::internal::configure::storage'

  $configfile = '/etc/xos/xtreemfs/osdconfig.properties'
  augeas { 'xtreemfs::configure::osd':
    context => "/files${configfile}",
    changes => $changes,
    incl    => $configfile,
    lens    => 'Properties.lns',
    require => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$anchor],
  }
  
  file { $object_dir:
    ensure  => 'directory',
    owner   => 'xtreemfs',
    group   => 'xtreemfs',
    require => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$anchor],
  }
  
  anchor { $anchor:
    notify => Anchor[$xtreemfs::internal::workflow::configure],
  }
}