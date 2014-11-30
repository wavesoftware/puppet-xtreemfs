require File.join(File.dirname(__FILE__), '../../../puppet_x/wavesoftware/xtreemfs/provider/xtfsutil')

# A puppet provider for type :xtreemfs_replicate
Puppet::Type.type(:xtreemfs_policy).provide(:xtfsutil, 
  :parent => Puppet_X::Wavesoftware::Xtreemfs::Provider::Xtfsutil) do
  desc "Manages xtreemfs_policy of directories of mounted XtreemFS filesystem"

  commands :xtfsutil => 'xtfsutil'

end