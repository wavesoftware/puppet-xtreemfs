require 'spec_helper'

describe 'xtreemfs_download_gpg', :type => :puppet_function do

  before :each do
    allow(Facter).to receive(:value).with(:kernel).and_return('Linux')
    allow(Facter).to receive(:value).with('fqdn').and_return('test-box.localdomain')
  end

  it do
    should run.
      with_params().and_raise_error(
        Puppet::ParseError, 
        'xtreemfs_download_gpg(): Wrong number of arguments given (0 for 1..2)'
      )
  end

  it do
    uri = 'http://download.opensuse.org/repositories/home:/xtreemfs/Debian_8.0/Release.key'
    should run.with_params(uri).and_return('19C11DC839B85E41B93F4E8207D6EA4F2FA7E736')
  end

  context 'simulating failure' do
    let (:last_exec_status) { double(:success? => false) }
    before :each do
      expect(Puppet_X::Wavesoftware::Xtreemfs::Functions).to receive(:execute).and_return('an-error')
      expect(Puppet_X::Wavesoftware::Xtreemfs::Functions).to receive(:last_exec_status).and_return(last_exec_status)
    end
    it do
      uri = 'http://download.opensuse.org/repositories/home:/xtreemfs/Debian_8.0/Release.key'
      should run.with_params(uri, 'default-hash').and_return('default-hash')
    end    
  end

end