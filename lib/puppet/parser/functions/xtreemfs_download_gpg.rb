require File.join(File.dirname(__FILE__), '../../../puppet_x/wavesoftware/xtreemfs/functions/xtreemfs_download_gpg')

# Standard puppet module for parser functions
module Puppet::Parser::Functions
  newfunction(:xtreemfs_download_gpg, :type => :rvalue, :doc => <<-EOS
    PRIVATE INTERNAL FUNCTION. Download a gpg key for debian based systems
    EOS
  ) do |args|

    Puppet_X::Wavesoftware::Xtreemfs::Functions.xtreemfs_download_gpg args
  end
end