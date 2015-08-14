# == Manages the replication of a file
#
# Manages a replication policy and replication factor of a file.
# It is applicable only to resources on XtreemFS filesystem mountpoint.
#
# === Parameters
#
# [*file*]
#     (namevar) A file to manage
# [*policy*]
#     The replication policy defines how a file is replicated. The policy
#     can be changed for a file that has replicas, but puppet will remove
#     all replicas before changing this property.
#     The following values (or its aliases stated in parentheses) can be used:
#
#     [+none+]
#         File is not replicated.
#     [+ronly+]
#         (+readonly+) File is read-only replicated and will be marked as read-only,
#         i.e. the file cannot be modified as long as the replication policy is set to ronly.
#     [+WqRq+]
#         (+quorum+), +WaR1+ (+all+) The file will be read-write replicated and can be modified. 
# [*factor*]
#     A replication factor. Defines on how many OSD servers target file should be replicated.
define xtreemfs::replicate (
  $policy = 'none',
  $factor = 1,
  $file   = $name,
) {
  include xtreemfs::internal::packages::client
  include xtreemfs::internal::workflow

  xtreemfs_replicate { $file:
    policy  => $policy,
    factor  => $factor,
    require => Anchor[$xtreemfs::internal::workflow::packages],
  }

  if defined(File[$file]) {
    File[$file] -> Xtreemfs_replicate[$file]
  }
}