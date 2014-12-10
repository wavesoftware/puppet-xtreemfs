require File.join(File.dirname(__FILE__), '../../../puppet_x/wavesoftware/xtreemfs/functions/directory_address')

# Standard puppet module for parser functions
module Puppet::Parser::Functions
  newfunction(:directory_address, :type => :rvalue, :doc => <<-EOS
    PRIVATE INTERNAL FUNCTION. Creates an address for directory service
    EOS
  ) do |args|

    Puppet_X::Wavesoftware::Xtreemfs::Functions.directory_address args
  end
end