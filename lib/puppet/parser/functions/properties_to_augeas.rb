require File.join(File.dirname(__FILE__), '../../../puppet_x/wavesoftware/xtreemfs/functions/properties_to_augeas')

# Standard puppet module for parser functions
module Puppet::Parser::Functions
  newfunction(:properties_to_augeas, :type => :rvalue, :doc => <<-EOS
    PRIVATE INTERNAL FUNCTION. Merges a given properties hash, with augeas 
    changes that must be applied in given configuration processor. 
    Returns in form aplicable by augeas.
    EOS
  ) do |args|

    Puppet_X::Wavesoftware::Xtreemfs::Functions.properties_to_augeas args
  end
end