# A puppet provider for type :xtreemfs_volume
Puppet::Type.type(:xtreemfs_volume).provide :xtreemfs do
  desc "Manages xtreemfs_volume of a logical volume"

  commands :mkfs_xtreemfs => 'mkfs.xtreemfs'
  commands :lsfs_xtreemfs => 'lsfs.xtreemfs'
  commands :rmfs_xtreemfs => 'rmfs.xtreemfs'

  # A constructor
  #
  # @param value [Hash] values for the provider, prefeched
  # @return [Puppet::Type::Xtreemfs_volume::Xtreemfs]
  def initialize value = {}
    super value
    @lskeys = [
      '--admin_password', 
      '-d', '--log-level', 
      '-l', '--log-file-path',
      '-h', '--help',
      '-V', '--version',
      '--pem-certificate-file-path',
      '--pem-private-key-file-path',
      '--pem-private-key-passphrase',
      '--pkcs12-file-path',
      '--pkcs12-passphrase',
      '--grid-ssl'
    ]
    @rmkeys = [
      '--globus-gridmap',
      '--unicore-gridmap',
      '--gridmap-location',
      '--gridmap-reload-interval-m'
    ].concat @lskeys
    @instances_raw = nil
    self
  end

  class << self
    attr_accessor :instances_raw
  end

  # Checks if given port is open
  #
  # @param host [String] a host to check, hostname or ip
  # @param port [Fixnum] a port to check
  # @return [Boolean]
  def self.is_port_open? host, port
    require 'socket'
    require 'timeout'
    begin
      Timeout::timeout(0.5) do
        begin
          s = TCPSocket.new host, port
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
          return false
        end
      end
    rescue Timeout::Error
    end

    return false
  end

  # Fetches a raw instances of volumes on this machine
  #
  # Has an blockade to fetch only once, so it can be executed many times without performance drop
  #
  # @return [Array] a list of instances in form of Hash
  def self.rawinstances
    unless self.instances_raw
      fqdn = Facter.value :fqdn
      if self.is_port_open?(fqdn, 32636)
        volumes = lsfs_xtreemfs fqdn
        self.instances_raw = parse volumes
      else
        self.instances_raw = []
      end
    end
    self.instances_raw
  end

  # Puppet instances method, that fetches instances for CLI
  #
  # @return [Array] a list of +Puppet::Type::Xtreemfs_volume::Xtreemfs+
  def self.instances
    rawinstances.collect do |vol|
      new vol
    end
  end

  # Loads an provider with data for volume
  #
  # @param vol [String] a volume name
  # @return [Puppet::Type::Xtreemfs_volume::Xtreemfs]
  def self.load_provider vol
    provider = nil
    found = rawinstances.find { |raw| raw[:name] == vol }
    provider = new(found) if found
    return provider
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

  # Parse an output of lsfs.xtreemfs command
  #
  # @param output [String] an output of lsfs.xtreemfs command
  # @return [Array] an list of hashes containg raw data
  def self.parse output
    re = /^\s*(.+?)\s*->\s*([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})\s*$/
    volumes = output.split("\n").select { |line| re.match line }
    volumes.collect do |l|
      m = re.match l
      name, uuid = m[1], m[2]
      {
        :name   => name,
        :ensure => :present,
        :uuid   => uuid
      }
    end
  end

  # Creates an resources in OS, part of +ensurable+ pupprt type
  #
  # @return [Puppet::Type::Xtreemfs_volume]
  def create
    mkfs
    @property_hash[:ensure] = :present
    @property_hash[:uuid] = uuid
    resource
  end

  # Checks if resource exists, part of +ensurable+ pupprt type
  #
  # @return [Boolean] +true+ if resource exists in OS
  def exists?
    if @property_hash[:ensure]
      @property_hash[:ensure] == :present
    else
      uuid != nil
    end
  end

  # Destroy resource in OS, part of +ensurable+ pupprt type
  #
  # @return [Puppet::Type::Xtreemfs_volume]
  def destroy
    rmfs
    @property_hash[:ensure] = :absent
    @property_hash[:uuid] = nil
    resource
  end

  # Property getter for +uuid+
  #
  # @return [String] an uuid of volume
  def uuid
    if @property_hash[:uuid]
      @property_hash[:uuid]
    else
      volumes = self.class.parse lsfs
      volume = volumes.find { |vol| vol[:name] == resource[:name] }
      return volume[:uuid] if volume
      return nil unless volume
    end
  rescue Puppet::ExecutionFailure
    nil
  end

  # Process oprions for system commands
  #
  # @param type [Symbol] type of command :lsfs, :mkfs, :rmfs
  # @return [Array] a list of opts for command line
  def options type
    opts = []
    if resource[:options]
      resource[:options].keys.sort.each do |key|
        value = resource[:options][key]
        value = nil if value == :undef
        value = value.to_s
        dashized = dashize(key.strip)
        if predicate(type).call(dashized)
          opts << dashized
          opts << value.strip unless value.strip.empty?
        end
      end
    end
    return opts
  end

  # Hypenize an opt, that meens adds dashes as prefix
  #
  # @param opt [String] a given option
  # @return [String] an option with dashes added
  def dashize opt
    if opt.start_with? '-'
      Puppet.warning "Passing options with dashes are deprecated. Pass only opt name. You have given: '#{opt}'"
      return opt
    else
      if opt.size > 1
        return "--#{opt}"
      else
        return "-#{opt}"
      end
    end
  end

  # A predicate for type, that returns +true+ if command line opts is applicable to given command type
  #
  # @param type [Symbol] type of command :lsfs, :mkfs, :rmfs
  # @return [Lambda] returns +true+ if command line opts is applicable to given command type
  def predicate type
    if type == :lsfs
      lambda { |key| @lskeys.include? key }
    elsif type == :rmfs
      lambda { |key| @rmkeys.include? key }
    else
      lambda { |key| true }
    end 
  end

  # Executes an lsfs command on OS
  #
  # @return [String] an ouptput of +lsfs.xtreemfs+
  def lsfs
    mkfs_options = options :lsfs
    mkfs_options << "#{resource[:host]}"

    lsfs_xtreemfs mkfs_options
  end

  # Executes an rmfs command on OS
  #
  # @return [String] an ouptput of +rmfs.xtreemfs+
  def rmfs
    mkfs_options = options :rmfs
    mkfs_options << '--force'
    mkfs_options << "#{resource[:host]}/#{resource[:name]}"

    rmfs_xtreemfs mkfs_options
  end

  # Executes an mkfs command on OS
  #
  # @return [String] an ouptput of +mkfs.xtreemfs+
  def mkfs
    mkfs_options = options :mkfs
    mkfs_options << "#{resource[:host]}/#{resource[:name]}"

    mkfs_xtreemfs mkfs_options
  end

end