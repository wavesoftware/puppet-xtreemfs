# == Role: Directory 
#
# Ensure that node will act as XtreemFS directory service.
#
# === Settings
#
# [*install_packages*]
#     If set to +true+ will install packages of XtreemFS, defaults: +true+
# [*add_repo*]
#     If set to +true+ will add to system repository for XtreemFS, defaults: +true+
# [*properties*]
#     A properties hash to provide configuration options in form exactly like: 
#     http://www.xtreemfs.org/xtfs-guide-1.5/index.html#tth_sEc3.2.6
#
class xtreemfs::role::directory (
  $install_packages = $xtreemfs::settings::install_packages,
  $add_repo         = $xtreemfs::settings::add_repo,
  $properties       = $xtreemfs::settings::properties,
) inherits xtreemfs::settings {
  
  include xtreemfs::internal::workflow

  if $install_packages {
    if $add_repo {
      include xtreemfs::internal::repo
    }
    include xtreemfs::internal::packages::server
  }

  class { 'xtreemfs::internal::configure::directory':
    properties => $properties,
  }
  
  service { 'xtreemfs-dir':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => Anchor[$xtreemfs::internal::workflow::configure],
    before     => Anchor[$xtreemfs::internal::workflow::service],
  }
}