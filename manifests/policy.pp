# == Manages the replication policy of directory
#
# Manages a replication policy and replication factor of new files inside directory.
# It is applicable only to resources on XtreemFS filesystem mountpoint.
#
# === Parameters
#
# [*directory*]
#     (namevar) A directory to manage
# [*policy*]
#     The replication policy defines how a files will be replicated.
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
#     A replication factor. Defines on how many OSD servers new file should be replicated.
define xtreemfs::policy (
  $policy    = 'none',
  $factor    = 1,
  $directory = $name,
) {
  include xtreemfs::internal::packages::client
  include xtreemfs::internal::workflow

  xtreemfs_policy { $directory:
    policy  => $policy,
    factor  => $factor,
    require => Anchor[$xtreemfs::internal::workflow::packages],
  }

  if defined(File[$directory]) {
    File[$directory] -> Xtreemfs_policy[$directory]
  }
}