$dir_host = 'master.vagrant.dev'

class { 'xtreemfs::settings':
  dir_host => $dir_host
}
include xtreemfs::role::storage

xtreemfs::mount { '/mnt/xtreemfs-myvolume':
  ensure   => 'mounted',
  dir_host => $dir_host,
  volume   => 'myVolume',
  atboot   => false,
}

$file = '/mnt/xtreemfs-myvolume/file1'
$dir = '/mnt/xtreemfs-myvolume/dir1'

file { $file:
  ensure  => 'file',
  content => 'This is some content!',
  require => Xtreemfs::Mount['/mnt/xtreemfs-myvolume'],
}

file { $dir:
  ensure  => 'directory',
  require => Xtreemfs::Mount['/mnt/xtreemfs-myvolume'],
}

xtreemfs::replicate { $file:
  policy  => 'WqRq',
  factor  => 2,
  require => File[$file],
}

xtreemfs::policy { $dir:
  policy => 'ronly',
  factor => 2,
}