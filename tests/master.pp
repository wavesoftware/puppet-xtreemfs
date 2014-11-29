class { 'xtreemfs::settings':
  properties => {
    'debug.level' => 7,
  },
}

include xtreemfs::role::directory
include xtreemfs::role::metadata
include xtreemfs::role::storage

xtreemfs::volume { 'myVolume':
  ensure      => 'present',
  dir_service => $::fqdn,
}

xtreemfs::mount { '/mnt/xtreemfs-myvolume':
  ensure      => 'mounted',
  dir_service => $::fqdn,
  volume      => 'myVolume',
  atboot      => false,
}