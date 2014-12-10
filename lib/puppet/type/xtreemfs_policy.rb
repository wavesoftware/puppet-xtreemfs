require File.join(File.dirname(__FILE__), '../../puppet_x/wavesoftware/xtreemfs/type/replicable')

# A type definition for xtreemfs_policy
Puppet::Type.newtype :xtreemfs_policy do

  desc "The xtreemfs_policy type"

  newparam :directory do
    isnamevar
  end

  Puppet_X::Wavesoftware::Xtreemfs::Type::Replicable.configure self

  validate do
    factor = self[:factor].to_s.to_i
    if self[:policy].to_sym == :none and factor > 1
      fail "If replication policy is set to `none`, you can't set replication factor to value greater then 1"
    end
    if self[:policy].to_sym != :none and factor <= 1
      fail "If replication policy is other then `none`, you must set set replication factor to value greater then 1"
    end
  end

end