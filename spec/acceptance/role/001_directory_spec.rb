require 'spec_helper_acceptance'

describe 'xtreemfs::role::directory class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  describe 'executing without installing packages' do
    pp = <<-eos
      class { 'xtreemfs::role::directory':
        install_packages => false,
      }
    eos
    it 'shouldn\'t work' do
      apply_manifest(pp, :expect_failures => true)
    end
  end
  
  describe 'executing without adding repo' do
    pp = <<-eos
      class { 'xtreemfs::role::directory':
        add_repo => false,
      }
    eos
    it 'shouldn\'t work' do
      apply_manifest(pp, :expect_failures => true)
    end
  end

  describe 'executing simple include with puppet code' do
    
    pp = <<-eos
    class { 'xtreemfs::settings': 
      properties => {
        'debug.level' => 2,
      }
    }
    include xtreemfs::role::directory
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :expect_changes => false)
    end
    describe service('xtreemfs-dir') do 
      it { should be_running }
    end
    it 'should leave a running service on http://localhost:30638/' do
      shell("curl -k http://localhost:30638/ > /dev/null", :acceptable_exit_codes => 0)
    end
    
  end

end