# A type definition for xtreemfs_volume
Puppet::Type.newtype(:xtreemfs_volume) do

  desc "The xtreemfs_volume type"

  ensurable

  newparam(:name) do
    isnamevar

    validate do |value|
      re = /^[a-zA-Z0-9_-]+$/
      unless re.match(value.to_s)
        fail "A name of volume must be only alphanumeric chars with exception for '_' and '-'"
      end
    end
  end

  newproperty :uuid do
    validate do |value|
      unless value.nil?
        fail "uuid property is read only!"
      end
    end
  end

  newparam(:host) do
    desc 'A host of volume, pass an directory service host here'
    defaultto Facter.value(:fqdn)
  end

  newparam(:options) do
    desc "Params for the mkfs command. eg. -l internal,agcount=x"
    defaultto {}
  end

end