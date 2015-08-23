# == Manages the replication policy of directory
#
# Manages a replication policy and replication factor of new files inside
# directory. It is applicable only to resources on XtreemFS filesystem
# mountpoint.
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
#         (+readonly+) File is read-only replicated and will be marked as 
#         read-only, i.e. the file cannot be modified as long as the 
#         replication policy is set to ronly.
#     [+WqRq+]
#         (+quorum+), +WaR1+ (+all+) The file will be read-write replicated and
#         can be modified. 
# [*factor*]
#     A replication factor. Defines on how many OSD servers new file should be
#     replicated. 
# [*striping_policy*]
#     XtreemFS currently supports the RAID0 striping pattern, which splits a
#     file up in a set of stripes of a fixed size, and distributes them across
#     a set of storage servers in a round-robin fashion. Since different
#     stripes can be accessed in parallel, the whole file can be read or
#     written with the aggregated network and storage bandwidth of multiple
#     servers.
# [*stripe_count*]
#     Number of storage servers used for striping, by default 1.
# [*stripe_size*]
#     The size of an individual stripe in KiB, no less then 4KiB, by default
#     128KiB
define xtreemfs::policy (
  $policy          = 'none',
  $factor          = 1,
  $striping_policy = 'RAID0',
  $stripe_count    = 1,
  $stripe_size     = 128,
  $directory       = $name,
) {
  include xtreemfs::internal::packages::client
  include xtreemfs::internal::workflow

  xtreemfs_policy { $directory:
    policy          => $policy,
    factor          => $factor,
    striping_policy => $striping_policy,
    stripe_count    => $stripe_count,
    stripe_size     => $stripe_size,
    require         => Anchor[$xtreemfs::internal::workflow::packages],
  }

  if defined(File[$directory]) {
    File[$directory] -> Xtreemfs_policy[$directory]
  }
}
