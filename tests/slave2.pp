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

$file = '/mnt/xtreemfs-myvolume/file1'

file { $file:
  ensure  => 'file',
  content => 'This is some content!',
  require => Xtreemfs::Mount['/mnt/xtreemfs-myvolume'],
}

xtreemfs::replicate { $file:
  policy  => 'WqRq',
  factor  => 2,
  require => File[$file],
}