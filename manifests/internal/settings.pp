# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::settings {
  
  $repobase = 'http://download.opensuse.org/repositories/home:/xtreemfs'
  
  $majorrelease = regsubst($::operatingsystemrelease, '^(\d+)\..*', '\1')
  
  # TODO: Expires in 2016-04, needs to be changed or downloaded by puppet
  $key = '19C11DC839B85E41B93F4E8207D6EA4F2FA7E736'
  
  $flavour = $::operatingsystem ? {
    'Debian'   => "Debian_${majorrelease}.0",
    'Ubuntu'   => "xUbuntu_${::operatingsystemrelease}",
    'RedHat'   => "RHEL_${majorrelease}",
    'Fedora'   => "Fedora_${majorrelease}",
    'SLES'     => "SLE_${::operatingsystemrelease}",
    'OpenSuSE' => "openSUSE_${::operatingsystemrelease}",
    /CentOS|OracleLinux|Scientific/ => "CentOS_${majorrelease}",
    default    => fail("Not supported operation system: ${::operatingsystem} ${::operatingsystemrelease}")
  }
}