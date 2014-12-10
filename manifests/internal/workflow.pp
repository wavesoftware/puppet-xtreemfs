# INTERNAL PRIVATE CLASS: do not use directly!
class xtreemfs::internal::workflow {
  
  $repo      = 'xtreemfs::repo'
  $packages  = 'xtreemfs::packages'
  $configure = 'xtreemfs::configure'
  $service   = 'xtreemfs::service'
  $end       = 'xtreemfs::end'
  
  anchor { $repo: } ->
  anchor { $packages: } ->
  anchor { $configure: } ~>
  anchor { $service: } ->
  anchor { $end: }
  
}