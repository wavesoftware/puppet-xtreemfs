Puppet::Type.type(:xtreemfs_replicate).provide :xtfsutil do
  desc "Manages xtreemfs_replicate of a files and directories of mounted XtreemFS filesystem"

  commands :xtfsutil => 'xtfsutil'

  def self.instances
    []
  end

  def self.prefetch_one file
    output = xtfsutil file
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

  def self.load_provider file
    props = prefetch_one file
    provider = new(
      :file   => file,
      :policy => correct_policy(props['Replication policy']),
      :factor => props['Replicas'].size
    )
    provider.rawprops props
    return provider
  end

  def self.correct_policy value
    if /^none\s+.*$/.match(value)
      'none'
    else
      value
    end
  end

  def self.prefetch resources
    resources.keys.each do |name|
      provider = load_provider name
      resources[name].provider = provider
    end
  end

  def flush
    flush_policy
    flush_factor
  end

  def flush_factor
    if @property_flush[:factor] and @property_flush[:factor] < @property_hash[:factor]
      unreplicate
    end
    if @property_flush[:factor]
      replicate
    end
  end

  def flush_policy
    if @property_flush[:policy]
      if factor > 1
        unreplicate
      end
      xtfsutil ['--set-replication-policy', @property_flush[:policy], @resource[:file]]
      @property_hash[:policy] = @property_flush[:policy]
    end
  end

  def unreplicate
    shuffled = @rawprops['Replicas'].shuffle[1..-1]
    shuffled.each do |repl|
      xtfsutil ['--delete-replica', repl[:osd_uuid], @resource[:file]]
      @property_hash[:factor] -= 1
    end
    @rawprops['Replicas'].reject { |el| shuffled.include? el }
    @property_flush[:factor] = @resource[:factor]
  end

  def replicate
    count = (@property_flush[:factor] - factor())
    osds = available_osds @resource[:file]
    if count > osds.size
      possible = osds.size + @property_hash[:factor]
      Puppet.warning "There is not enough available OSD servers to adjust replication" +
        " factor to: #{@property_flush[:factor]}. Setting replication factor to highest" +
        " possible value: #{possible}"
      count = osds.size
    end
    count.times do 
      xtfsutil ['--add-replica', 'auto', @resource[:file]]
      @property_hash[:factor] += 1
    end
  end

  def available_osds file
    re = /\s+([a-fA-F0-9-]+)\s+\((.+)\)/
    osds = xtfsutil(['--list-osds', @resource[:file]]).split("\n")[1..-1]
    osds.collect do |line|
      all, uuid, address = re.match(line).to_a
      {
        :uuid    => uuid,
        :address => address
      }
    end
  end

  def initialize value = {}
    super value
    @property_flush = {}
    @rawprops = nil
  end

  def rawprops props
    @rawprops = props
  end

  def policy
    @property_hash[:policy] || :absent
  end

  def factor
    @property_hash[:factor] || :absent
  end

  def policy= value
    @property_flush[:policy] = value
  end

  def factor= value
    @property_flush[:factor] = value
  end
end