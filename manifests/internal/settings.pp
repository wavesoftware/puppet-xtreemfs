# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::settings {
  
  $repobase = 'http://download.opensuse.org/repositories/home:/xtreemfs'
  
  $majorrelease = regsubst($::operatingsystemrelease, '^(\d+)\..*', '\1')
  
  $key = '07D6EA4F2FA7E736'
  
  $flavour = $::operatingsystem ? {
    'Debian'   => "Debian_${::operatingsystemrelease}",
    'Ubuntu'   => "xUbuntu_${::operatingsystemrelease}",
    'RedHat'   => "RHEL_${majorrelease}",
    'Fedora'   => "Fedora_${majorrelease}",
    'SLES'     => "SLE_${::operatingsystemrelease}",
    'OpenSuSE' => "openSUSE_${::operatingsystemrelease}",
    /CentOS|OracleLinux|Scientific/ => "CentOS_${majorrelease}",
    default    => fail("Not supported operation system: ${::operatingsystem} ${::operatingsystemrelease}")
  }
}