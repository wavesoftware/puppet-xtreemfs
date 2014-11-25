Puppet::Type.type(:xtreemfs_volume).provide :xtreemfs do
    desc "Manages xtreemfs_volume of a logical volume"

    commands :mkfs_xtreemfs => 'mkfs.xtreemfs'
    commands :lsfs_xtreemfs => 'lsfs.xtreemfs'
    commands :rmfs_xtreemfs => 'rmfs.xtreemfs'

    def create
        mkfs
    end

    def exists?
        uuid != nil
    end

    def destroy
        rmfs
    end

    def uuid
        re = /^\s*(.+?)\s*->\s*([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})\s*$/
        out = lsfs
        uid = nil
        out.split("\n").each do |l|
            m = re.match l
            unless m.nil?
                name, id = m[1], m[2]
                if name == @resource[:name]
                    uid = id
                    break
                end
            end
        end
        uid
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
        opts
    end

    def lsfs
        mkfs_options = options :lsfs
        mkfs_options << "#{@resource[:host]}/#{@resource[:name]}"

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