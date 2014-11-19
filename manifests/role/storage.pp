# == Role: Storage 
#
# Ensure that node will act as XtreemFS storage node.
#
# === Settings
#
# [*dir_service*]      
#     Provide an host to where metadata and storage nodes will be connecting, defaults: <tt>$::fqdn</tt>
# [*object_dir*]
#     A direcory where storage nodes will hold their replicated data. Good idea is to provide 
#     a directory on secure RAID drive, defaults: +/var/lib/xtreemfs/objs+
# [*install_packages*]
#     If set to +true+ will install packages of XtreemFS, defaults: +true+
# [*add_repo*]
#     If set to +true+ will add to system repository for XtreemFS, defaults: +true+
# [*extra*]
#     An extra hash to provide other configuration options in form exactly like: 
#     http://www.xtreemfs.org/xtfs-guide-1.5/index.html#tth_sEc3.2.6
#
class xtreemfs::role::storage (
  $dir_service      = $xtreemfs::settings::dir_service,
  $object_dir       = $xtreemfs::settings::object_dir,
  $install_packages = $xtreemfs::settings::install_packages,
  $add_repo         = $xtreemfs::settings::add_repo,
  $extra            = $xtreemfs::settings::extra,
) inherits xtreemfs::settings {
  
  include xtreemfs::internal::workflow

  if $install_packages {
    if $add_repo {
      include xtreemfs::internal::repo
    }
    include xtreemfs::internal::packages::server
  }
  
  class { 'xtreemfs::internal::configure::storage':
    dir_service => $dir_service,
    object_dir  => $object_dir,
    extra       => $extra,
  }
  
  service { 'xtreemfs-osd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => Anchor[$xtreemfs::internal::workflow::configure],
    before     => Anchor[$xtreemfs::internal::workflow::service],
  }
}