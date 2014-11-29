$dir = 'master.vagrant.dev'

class { 'xtreemfs::settings':
  dir_service => $dir
}
include xtreemfs::role::storage

xtreemfs::mount { '/mnt/xtreemfs-myvolume':
  ensure      => 'mounted',
  dir_service => $dir,
  volume      => 'myVolume',
  atboot      => false,
}