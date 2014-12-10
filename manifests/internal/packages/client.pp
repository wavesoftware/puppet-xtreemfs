# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::packages::client {
  
  include xtreemfs::internal::workflow
  
  $packages = ['xtreemfs-client', 'xtreemfs-tools']
  ensure_packages($packages)
  
  Anchor[$xtreemfs::internal::workflow::repo] ->
  Package[$packages] ->
  Anchor[$xtreemfs::internal::workflow::packages]
}