# A type definition for xtreemfs_volume
Puppet::Type.newtype(:xtreemfs_volume) do

  desc "The xtreemfs_volume type"

  ensurable

  newparam(:name) do
    isnamevar
  end

  newparam(:host) do
    desc 'A host of volume, pass an directory service host here'
  end

  newparam(:options) do
    desc "Params for the mkfs command. eg. -l internal,agcount=x"
  end

end