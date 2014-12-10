# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::packages::server {
  
  include xtreemfs::internal::workflow
  $packages = ['xtreemfs-server']
  ensure_packages($packages)
  
  Anchor[$xtreemfs::internal::workflow::repo] ->
  Package[$packages] ->
  Anchor[$xtreemfs::internal::workflow::packages]
}