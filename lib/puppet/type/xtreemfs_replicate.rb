require File.join(File.dirname(__FILE__), '../../puppet_x/wavesoftware/xtreemfs/type/replicable')

# A type definition for xtreemfs_replicate
Puppet::Type.newtype :xtreemfs_replicate do

  desc "The xtreemfs_replicate type"

  newparam :file do
    isnamevar
  end

  newproperty :factor do
    Puppet_X::Wavesoftware::Xtreemfs::Type::Replicable.configure_factor(self)
  end

  newproperty :policy do
    Puppet_X::Wavesoftware::Xtreemfs::Type::Replicable.configure_policy(self)
  end

  Puppet_X::Wavesoftware::Xtreemfs::Type::Replicable.configure_global_validation(self)

end