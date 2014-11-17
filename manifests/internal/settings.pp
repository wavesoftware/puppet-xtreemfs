# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::settings {
  
  $repobase = 'http://download.opensuse.org/repositories/home:/xtreemfs'
  
  $flavour = $::operatingsystem ? {
    'Debian'   => "Debian_${::operatingsystemrelease}",
    'Ubuntu'   => "xUbuntu_${::operatingsystemrelease}",
    'RedHat'   => "RHEL_${::operatingsystemmajrelease}",
    'Fedora'   => "Fedora_${::operatingsystemmajrelease}",
    'SLES'     => "SLE_${::operatingsystemrelease}",
    'OpenSuSE' => "openSUSE_${::operatingsystemrelease}",
    /CentOS|OracleLinux|Scientific/ => "CentOS_${::operatingsystemmajrelease}",
    default    => fail("Not supported operation system: ${::operatingsystem}")
  }
}