class { 'xtreemfs::settings':
  properties => {
    'debug.level' => 6,
  },
}

include xtreemfs::role::directory
include xtreemfs::role::metadata
include xtreemfs::role::storage

xtreemfs::volume { 'myVolume':
  ensure      => 'present',
  dir_service => $::fqdn,
}