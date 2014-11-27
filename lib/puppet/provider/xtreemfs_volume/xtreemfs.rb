Puppet::Type.type(:xtreemfs_volume).provide :xtreemfs do
  desc "Manages xtreemfs_volume of a logical volume"

  commands :mkfs_xtreemfs => 'mkfs.xtreemfs'
  commands :lsfs_xtreemfs => 'lsfs.xtreemfs'
  commands :rmfs_xtreemfs => 'rmfs.xtreemfs'

  def self.rawinstances
    fqdn = Facter.value :fqdn
    volumes = lsfs_xtreemfs fqdn
    parse volumes
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
  end

  def uuid
    if @property_hash[:uuid]
      @property_hash[:uuid]
    else
      volumes = self.class.parse lsfs
      return volumes.find { |vol| vol[:name] == @resource[:name] }
    end
  rescue Puppet::ExecutionFailure
    nil
  end

  def options type
    opts = []
    lskeys = [
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
    rmkeys = [
      '--globus-gridmap',
      '--unicore-gridmap',
      '--gridmap-location',
      '--gridmap-reload-interval-m'
    ].concat lskeys

    predicate = if type == :lsfs
      lambda { |key| lskeys.include? key }
    elsif type == :rmfs
      lambda { |key| rmkeys.include? key }
    else
      lambda { |key| true }
    end 
    if @resource[:options]
      @resource[:options].each do |key, value|
        if predicate key
          opts << "#{key} #{value}"
        end
      end
    end
    return opts
  end

  def lsfs
    mkfs_options = options :lsfs
    mkfs_options << "#{@resource[:host]}"

    lsfs_xtreemfs mkfs_options
  end

  def rmfs
    mkfs_options = options :rmfs
    mkfs_options << '--force'
    mkfs_options << "#{@resource[:host]}/#{@resource[:name]}"

    rmfs_xtreemfs mkfs_options
  end

  def mkfs
    mkfs_options = options :mkfs
    mkfs_options << "#{@resource[:host]}/#{@resource[:name]}"

    mkfs_xtreemfs mkfs_options
  end

end