require File.join(File.dirname(__FILE__), '../../../puppet_x/wavesoftware/xtreemfs/provider/xtfsutil')

# A puppet provider for type :xtreemfs_replicate
Puppet::Type.type(:xtreemfs_replicate).provide(:xtfsutil, 
  :parent => Puppet_X::Wavesoftware::Xtreemfs::Provider::Xtfsutil) do

  desc "Manages xtreemfs_replicate of a files of mounted XtreemFS filesystem"

  commands :xtfsutil => 'xtfsutil'

  # Loads an raw data for file
  #
  # @param file [String] a file name
  # @return [Hash] a raw data hash
  def self.prefetch_one file
    output = xtfsutil_cmd file
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
      :policy => correct_policy(props['Replication policy']).to_sym,
      :factor => props['Replicas'].size
    )
    provider.rawprops = props
    return provider
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

  # Actually sets a policy to the OS
  #
  # @return [String] a command output
  def set_policy
    xtfsutil ['--set-replication-policy', @property_flush[:policy], resource[:file]]
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

end