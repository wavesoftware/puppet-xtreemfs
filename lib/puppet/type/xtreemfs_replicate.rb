require File.join(File.dirname(__FILE__), '../../puppet_x/wavesoftware/xtreemfs/type/replicable')

# A type definition for xtreemfs_replicate
Puppet::Type.newtype :xtreemfs_replicate do

  desc "The xtreemfs_replicate type"

  newparam :file do
    isnamevar
  end

  Puppet_X::Wavesoftware::Xtreemfs::Type::Replicable.configure self

end