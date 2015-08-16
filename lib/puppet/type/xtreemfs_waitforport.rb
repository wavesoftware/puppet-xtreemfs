# Private type
Puppet::Type.newtype :xtreemfs_waitforport do
  newparam(:timeout) do
    defaultto 60
  end
  newparam(:ip) do
    defaultto 'localhost'
  end
  newparam(:name) do
    isnamevar
  end
  newproperty(:open) do
    isnamevar
    munge do |value|
      value.to_s.to_i
    end
    def is_to_s value
      value.inspect
    end
  end
end
