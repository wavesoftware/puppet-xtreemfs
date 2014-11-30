require File.join(File.dirname(__FILE__), '../../puppet_x/wavesoftware/xtreemfs/type/replicable')

# A type definition for xtreemfs_policy
Puppet::Type.newtype :xtreemfs_policy do

  desc "The xtreemfs_policy type"

  newparam :directory do
    isnamevar
  end

  Puppet_X::Wavesoftware::Xtreemfs::Type::Replicable.configure self

end