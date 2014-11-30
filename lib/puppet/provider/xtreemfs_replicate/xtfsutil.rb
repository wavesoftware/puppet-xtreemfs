# A puppet provider for type :xtreemfs_replicate
Puppet::Type.type(:xtreemfs_replicate).provide :xtfsutil do
  desc "Manages xtreemfs_replicate of a files and directories of mounted XtreemFS filesystem"

  commands :xtfsutil => 'xtfsutil'

  # Puppet instances method, that fetches instances for CLI
  #
  # @return [Array] a list of +Puppet::Type::Xtreemfs_replicate::Xtfsutil+
  def self.instances
    []
  end

  # Loads an raw data for file
  #
  # @param file [String] a file name
  # @return [Hash] a raw data hash
  def self.prefetch_one file
    output = xtfsutil file
    unless /Path \(on volume\)/m.match output
      fail 'Tring to replicate file, that is not on XtreemFS volume? :' + output
    end
    propss, replicass = output.split /Replicas:/
    re = /(.+)\s{2,}(.+)/
    props = {}
    propss.split("\n").each do |line|
      m = re.match line
      key = m[1].strip
      value = m[2].strip
      props[key] = value
    end
    re = /\s+Striping policy\s+(.+?)\s+\/\s+(.+?)\s+\/\s+(.+?)\n\s+OSD\s+([0-9]+)\s+([a-fA-F0-9-]+)\s+\((.+)\)/m
    replicas = []
    replicass.split(/\s*Replica\s+[0-9]+\n/)[1..-1].each do |line|
      all, strip, strip_n, strip_size, osd, uuid, address = re.match(line).to_a
      props['Striping'] = strip
      props['Striping count'] = strip_n
      props['Striping size'] = strip_size
      replicas << {
        :strip       => strip,
        :strip_n     => strip_n,
        :strip_size  => strip_size,
        :osd         => osd,
        :osd_uuid    => uuid,
        :osd_address => address
      }
    end
    props['Replicas'] = replicas
    return props
  end

  # A constructor
  #
  # @param value [Hash] values for the provider, prefeched
  # @return [Puppet::Type::Xtreemfs_replicate::Xtfsutil]
  def initialize value = {}
    super value
    @property_flush = {}
    @rawprops = nil
    self
  end

  # A rawprops setter
  #
  # @param props [Hash] a raw properties
  # @return [Hash] raw properties
  def rawprops= props
    @rawprops = props
  end

  # Loads an provider with data for file
  #
  # @param file [String] a file name
  # @return [Puppet::Type::Xtreemfs_replicate::Xtfsutil]
  def self.load_provider file
    unless File.file? file
      return nil
    end
    props = prefetch_one file
    provider = new(
      :file   => file,
      :policy => correct_policy(props['Replication policy']),
      :factor => props['Replicas'].size
    )
    provider.rawprops = props
    return provider
  end

  # Corrects a policy that is outputed by xtfsutil commandline tool
  #
  # @param value [String] an input form
  # @return [String] an corrected form
  def self.correct_policy value
    if /^none\s+.*$/.match(value)
      'none'
    else
      value
    end
  end

  # A puppet prefetch method, that prefetches instances for management runs
  #
  # @param resources [Hash] a hash of resources in form of :name => resource
  # @return [Hash] a filled up hash
  def self.prefetch resources
    resources.keys.each do |name|
      if (provider = load_provider name)
        resources[name].provider = provider
      end
    end
  end

  # Validates if target file can be used as a target for xtfsutil commandline tool
  #
  # @return [nil]
  def validate
    unless File.exists? resource[:file]
      fail "A file for replicate must exists, but it doesn't - #{resource[:file]}"
    end
    unless File.file? resource[:file]
      type = File.stat(resource[:file]).ftype
      fail "A file for replicate must be regular file, but #{type} given - #{resource[:file]}"
    end
    nil
  end

  # Puppet flush method
  #
  # Used for flushing all operations in one place. In this case it is used to 
  # maintain order of operations.
  #
  # @return [nil]
  def flush
    validate
    flush_policy
    flush_factor
    return nil
  end

  # Flushes a factor property
  #
  # @return [nil]
  def flush_factor
    if @property_flush[:factor] and @property_flush[:factor] < @property_hash[:factor]
      unreplicate
    end
    if @property_flush[:factor]
      replicate
    end
    return nil
  end

  # Flushes a policy property
  #
  # @return [nil]
  def flush_policy
    if @property_flush[:policy]
      if factor > 1
        unreplicate
      end
      xtfsutil ['--set-replication-policy', @property_flush[:policy], resource[:file]]
      @property_hash[:policy] = @property_flush[:policy]
    end
    return nil
  end

  # Ensures that target file has no replicas
  #
  # @return [nil]
  def unreplicate
    shuffled = @rawprops['Replicas'].shuffle[1..-1]
    shuffled.each do |repl|
      xtfsutil ['--delete-replica', repl[:osd_uuid], resource[:file]]
      @property_hash[:factor] -= 1
    end
    @rawprops['Replicas'].reject { |el| shuffled.include? el }
    @property_flush[:factor] = resource[:factor]
    return nil
  end

  # Ensures that target file has so many replicas to match :factor property
  #
  # @return [nil]
  def replicate
    count = (@property_flush[:factor] - factor())
    osds = available_osds resource[:file]
    if count > osds.size
      possible = osds.size + @property_hash[:factor]
      Puppet.warning "There is not enough available OSD servers to adjust replication" +
        " factor to: #{@property_flush[:factor]}. Setting replication factor to highest" +
        " possible value: #{possible}"
      count = osds.size
    end
    count.times do 
      xtfsutil ['--add-replica', 'auto', resource[:file]]
      @property_hash[:factor] += 1
    end
    return nil
  end

  # Gets available osds for given file
  #
  # @return [Array] a list of available OSD servers that can be used to replicate given file
  def available_osds file
    re = /\s+([a-fA-F0-9-]+)\s+\((.+)\)/
    osds = xtfsutil(['--list-osds', resource[:file]]).split("\n")[1..-1]
    osds.collect do |line|
      all, uuid, address = re.match(line).to_a
      {
        :uuid    => uuid,
        :address => address
      }
    end
  end

  # A policy getter
  #
  # @return [String] a policy
  def policy
    @property_hash[:policy] || nil
  end

  # A factor getter
  #
  # @return [String] a factor
  def factor
    @property_hash[:factor] || nil
  end

  # A policy setter
  #
  # @param value [String] a policy
  # @return [String] a policy
  def policy= value
    validate
    @property_flush[:policy] = value
  end

  # A factor setter
  #
  # @param value [String] a factor
  # @return [String] a factor
  def factor= value
    validate
    @property_flush[:factor] = value
  end
end