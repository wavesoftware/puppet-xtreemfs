$dir = 'master.vagrant.dev'

class { 'xtreemfs::settings':
  dir_host => $dir
}
include xtreemfs::role::storage

xtreemfs::mount { '/mnt/xtreemfs-myvolume':
  ensure   => 'mounted',
  dir_host => $dir,
  volume   => 'myVolume',
  atboot   => false,
}