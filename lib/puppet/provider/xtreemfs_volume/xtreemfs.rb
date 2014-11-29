Puppet::Type.type(:xtreemfs_volume).provide :xtreemfs do
  desc "Manages xtreemfs_volume of a logical volume"

  commands :mkfs_xtreemfs => 'mkfs.xtreemfs'
  commands :lsfs_xtreemfs => 'lsfs.xtreemfs'
  commands :rmfs_xtreemfs => 'rmfs.xtreemfs'

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
  end

  class << self
    attr_accessor :instances_raw
  end

  def self.is_port_open? host, port
    require 'socket'
    require 'timeout'
    begin
      Timeout::timeout(0.2) do
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

  def self.instances
    rawinstances.collect do |vol|
      new vol
    end
  end

  def self.load_provider vol
    provider = nil
    found = rawinstances.find { |raw| raw[:name] == vol }
    provider = new(found) if found
    return provider
  end

  def self.prefetch resources
    resources.keys.each do |name|
      if (provider = load_provider name)
        resources[name].provider = provider
      end
    end
  end

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

  def create
    mkfs
    @property_hash[:ensure] = :present
    @property_hash[:uuid] = uuid
    resource
  end

  def exists?
    if @property_hash[:ensure]
      @property_hash[:ensure] == :present
    else
      uuid != nil
    end
  end

  def destroy
    rmfs
    @property_hash[:ensure] = :absent
    @property_hash[:uuid] = nil
    resource
  end

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

  def options type
    opts = []
    if resource[:options]
      resource[:options].each do |key, value|
        if predicate(type).call(key)
          opts << "#{key} #{value}".strip
        end
      end
    end
    return opts.sort
  end

  def predicate type
    if type == :lsfs
      lambda { |key| @lskeys.include? key }
    elsif type == :rmfs
      lambda { |key| @rmkeys.include? key }
    else
      lambda { |key| true }
    end 
  end

  def lsfs
    mkfs_options = options :lsfs
    mkfs_options << "#{resource[:host]}"

    lsfs_xtreemfs mkfs_options
  end

  def rmfs
    mkfs_options = options :rmfs
    mkfs_options << '--force'
    mkfs_options << "#{resource[:host]}/#{resource[:name]}"

    rmfs_xtreemfs mkfs_options
  end

  def mkfs
    mkfs_options = options :mkfs
    mkfs_options << "#{resource[:host]}/#{resource[:name]}"

    mkfs_xtreemfs mkfs_options
  end

end