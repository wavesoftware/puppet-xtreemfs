# A puppet x module
module Puppet_X
# A Wavesoftware puppet_x module
module Wavesoftware
# XtreemFS module
module Xtreemfs
# A custom class that holds custom functions
class Functions

  # PRIVATE INTERNAL FUNCTION. Creates an address for directory service
  #
  # @param args [Array] tree or four elements array. First element is explicit hostname, 
  #                     second is a port, third is a protocol. The last one if it is passed 
  #                     is default value to use.
  # @return [Array] an compiled address for directory service
  def self.directory_address args
    unless [3,4].include? args.size
      raise(Puppet::ParseError, "directory_address(): Wrong number of arguments given (#{args.size} for 3..4)")
    end
    require 'uri' 
    fqdn           = Facter.value :fqdn
    address        = URI.parse "//#{fqdn}"
    host           = notnil args[0]
    port           = notnil args[1]
    scheme         = notnil args[2]
    defaultAddress = notnil args[3]

    if host
      address.host = host
    end
    if port
      address.port = port
    end
    if scheme
      address.scheme = scheme
    end
    unless defaultAddress.nil?
      unless defaultAddress.include? '//'   
        defaultAddress = "//#{defaultAddress}"
      end
      uri = URI.parse defaultAddress
      if host.nil? and not uri.host.nil?
        address.host = uri.host
      end
      if port.nil? and not uri.port.nil?
        address.port = uri.port
      end
      if scheme.nil? and not uri.scheme.nil?
        address.scheme = uri.scheme
      end
    end
    return address.to_s.gsub /^\/\//, ''
  end

  private

  # Gets a not nil value or nil
  #
  # @param value [String,nil] a string value or nil
  # @return [String,nil] an value
  def self.notnil value
    if value.nil? 
      return nil
    end
    if value.to_s.empty?
      return nil
    end
    return value
  end

end
end
end
end