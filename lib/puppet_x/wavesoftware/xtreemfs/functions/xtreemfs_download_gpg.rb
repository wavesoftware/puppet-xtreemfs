# A puppet x module
module Puppet_X
# A Wavesoftware puppet_x module
module Wavesoftware
# XtreemFS module
module Xtreemfs
# A custom class that holds custom functions
class Functions

  # PRIVATE INTERNAL FUNCTION. Download a gpg key for debian based systems
  #
  # @param args [Array] two arguments. First element is download link for GPG key. 
  #                     The second is default value in case it could not get downloaded.
  # @return [Array] an GPG fingerprint
  def self.xtreemfs_download_gpg args
    raise(Puppet::ParseError, "xtreemfs_download_gpg(): Wrong number of arguments " +
      "given (#{args.size} for 1..2)") if args.size != 1 and args.size != 2
    begin
      f = Tempfile.new 'xtreemfs_download_gpg'
      address, default_value = args
      require 'net/http'
      require 'tempfile'
      uri = URI.parse(address)
      key = Net::HTTP::get(uri)
      f.write(key)
      f.flush
      lines = self.execute("gpg --with-fingerprint #{f.path}")
      raise lines unless self.last_exec_status.success?
      last_line = lines.split("\n")[-1]
      last_line.split(/\s+=\s+/)[-1].gsub(' ', '')
    rescue
      default_value
    ensure
      f.unlink
    end
  end

  def self.execute(command)
    `#{command}`
  end

  def self.last_exec_status
    $?
  end

end
end
end
end