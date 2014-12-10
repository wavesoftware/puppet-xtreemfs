# == A global settings
#
# You can set those settings and just include classes for roles. See README.md
#
# === Settings
#
# [*dir_host*]
#     Provide an host to where metadata and storage nodes will be connecting, defaults: <tt>$::fqdn</tt>
# [*dir_port*]
#     A port for directory service connection
# [*dir_protocol*]
#     A protocol for directory service connection
# [*object_dir*]
#     A direcory where storage nodes will hold their replicated data. Good idea is to provide 
#     a directory on secure RAID drive, defaults: +/var/lib/xtreemfs+
# [*install_packages*]
#     If set to +true+ will install packages of XtreemFS, defaults: +true+
# [*add_repo*]
#     If set to +true+ will add to system repository for XtreemFS, defaults: +true+
# [*properties*]
#     A properties hash to provide configuration options in form exactly like: 
#     http://www.xtreemfs.org/xtfs-guide-1.5/index.html#tth_sEc3.2.6
#
class xtreemfs::settings (
  $dir_host         = $::fqdn,
  $dir_port         = undef,
  $dir_protocol     = undef,
  $object_dir       = '/var/lib/xtreemfs',
  $install_packages = true,
  $add_repo         = true,
  $properties       = {},
) {
  include xtreemfs::internal::settings
  
  $flavour  = $xtreemfs::internal::settings::flavour
  $key      = $xtreemfs::internal::settings::key
  $repobase = $xtreemfs::internal::settings::repobase

  $dir_service = directory_address($dir_host, $dir_port, $dir_protocol)
}