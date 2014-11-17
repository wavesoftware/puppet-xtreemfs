# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::repo {
  include xtreemfs::internal::workflow
  include xtreemfs::settings
  
  $repo = "${xtreemfs::settings::repobase}/${xtreemfs::settings::flavour}"
  
  case $::osfamily {
    'RedHat': {
      yumrepo { 'xtreemfs':
        enabled  => 1,
        baseurl  => $repo,
        gpgcheck => 1,
        gpgkey   => "${repo}/repodata/repomd.xml.key",
        before   => Anchor[$xtreemfs::internal::workflow::repo],
      }
    }
    'Debian': {
      apt::source { 'xtreemfs':
        ensure     => 'present',
        location   => $repo,
        repos      => './',
        key_source => "${repo}/Release.key",
      }
      include apt::update
      Exec['apt_update'] -> Anchor[$xtreemfs::internal::workflow::repo]
    }
    default: {
      fail("Unsupported operation system family: ${::osfamily}")
    }
  }
  
}