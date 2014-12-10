require 'spec_helper_acceptance'

describe 'xtreemfs::volume define', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  describe 'creating with default params' do
    
    pp = <<-eos
    class { 'xtreemfs::settings':
      dir_host => 'localhost',
    }
    include xtreemfs::role::directory
    include xtreemfs::role::metadata
    include xtreemfs::role::storage

    xtreemfs::volume { 'myVolume': }
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :expect_changes => false)
    end
    
  end

  describe 'purging with defaults' do
    pp = <<-eos
    class { 'xtreemfs::settings':
      dir_host => 'localhost',
    }
    include xtreemfs::role::directory
    include xtreemfs::role::metadata
    include xtreemfs::role::storage

    xtreemfs::volume { 'myVolume':
      ensure => 'absent',
    }
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :expect_changes => false)
    end
  end

  describe 'creating with various options' do
    
    pp = <<-eos
    class { 'xtreemfs::settings':
      dir_host => 'localhost',
    }
    include xtreemfs::role::directory
    include xtreemfs::role::metadata
    include xtreemfs::role::storage

    xtreemfs::volume { 'vmail':
      ensure      => 'present',
      options     => {
        'admin_password' => 'some-passwd',
        'd'              => 'DEBUG',
        'chown-non-root' => undef,
        'log-file-path'  => '/tmp/xtreemfs.log',
      },
    }
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :expect_changes => false)
    end
    
  end

  describe 'purging with various options' do
    pp = <<-eos
    class { 'xtreemfs::settings':
      dir_host => 'localhost',
    }
    include xtreemfs::role::directory
    include xtreemfs::role::metadata
    include xtreemfs::role::storage

    xtreemfs::volume { 'vmail':
      ensure      => 'absent',
      options     => {
        'admin_password' => 'some-passwd',
        'd'              => 'DEBUG',
        'chown-non-root' => undef,
        'log-file-path'  => '/tmp/xtreemfs.log',
      },
    }
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :expect_changes => false)
    end
  end

end