# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::configure::metadata (
  $dir_service
) {
  include xtreemfs::internal::workflow
  augeas { 'xtreemfs::configure::mrc':
    context => '/files/etc/xos/xtreemfs/mrcconfig.properties',
    changes => "set dir_service.host ${dir_service}",
    require => Anchor[$xtreemfs::internal::workflow::packages],
    notify  => Anchor[$xtreemfs::internal::workflow::configure],
  }
}