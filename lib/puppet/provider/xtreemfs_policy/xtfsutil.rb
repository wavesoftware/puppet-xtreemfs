require File.join(File.dirname(__FILE__), '../../../puppet_x/wavesoftware/xtreemfs/provider/xtfsutil')

# A puppet provider for type :xtreemfs_replicate
Puppet::Type.type(:xtreemfs_policy).provide(:xtfsutil, 
  :parent => Puppet_X::Wavesoftware::Xtreemfs::Provider::Xtfsutil) do
  desc "Manages xtreemfs_policy of directories of mounted XtreemFS filesystem"

  commands :xtfsutil => 'xtfsutil'

  # Loads an raw data for directory
  #
  # @param directory [String] a directory name
  # @return [Hash] a raw data hash
  def self.prefetch_one directory
    output = xtfsutil_cmd directory
    re = /(.+)\s{2,}(.+)/
    props = {}
    output.split("\n").each do |line|
      m = re.match line
      key = m[1].strip
      value = m[2].strip
      props[key] = value
    end
    return props
  end

  # Loads an provider with data for directory
  #
  # @param directory [String] a directory name
  # @return [Puppet::Type::Xtreemfs_replicate::Xtfsutil]
  def self.load_provider directory
    unless File.directory? directory
      return nil
    end
    props = prefetch_one directory
    parsed = parse_drp props['Default Repl. p.']
    provider = new(
      :directory => directory,
      :policy    => parsed[:policy],
      :factor    => parsed[:factor]
    )
    provider.rawprops = props
    return provider
  end

  # Parse a default replication policy string
  #
  # @param srp [String] a string that represents a default replication policy
  #     as outputed by xtfsutil command
  # @return [Hash] a parsed hash with +:policy+ and +:factor+ keys
  def self.parse_drp drp
    parsed = {}
    if drp == 'not set'
      return { :policy => :none, :factor => 1 }
    end
    re = /^([^\s]+) with (\d+) replicas.*$/
    m = re.match drp
    if m
      parsed[:policy] = m[1].to_sym
      parsed[:factor] = m[2].to_i
    end
    return parsed
  end

  # Validates if target directory can be used as a target for xtfsutil commandline tool
  #
  # @return [nil]
  def validate
    if resource[:policy] != :none and resource[:factor] <= 1
      fail "A replication factor must be greater then 1"
    end
    unless File.exists? resource[:directory]
      fail "A directory for policy must exists, but it doesn't - #{resource[:directory]}"
    end
    unless File.directory? resource[:directory]
      type = File.stat(resource[:directory]).ftype
      fail "A directory for policy must be a directory, but #{type} given - #{resource[:directory]}"
    end
    return nil
  end

  # Flushes all other properties
  # @return [String] xtfsutil output
  def flush_all
    output = xtfsutil [
      '--set-drp', 
      '--replication-policy', resource[:policy], 
      '--replication-factor', resource[:factor], 
      resource[:directory]
    ]
    @property_hash[:policy] = resource[:policy]
    @property_hash[:factor] = resource[:factor]
    return output
  end

  # Actually sets a policy to the OS
  #
  # @return [String] a command output
  def set_policy
    # do nothing here
    return nil    
  end

  # Do nothing for policy type
  #
  # @return [nil]
  def unreplicate
    return nil
  end

  # Do nothing for policy type
  #
  # @return [nil]
  def replicate
    return nil
  end

end