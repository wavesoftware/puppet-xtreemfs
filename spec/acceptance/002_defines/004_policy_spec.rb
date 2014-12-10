require 'spec_helper_acceptance'

describe 'xtreemfs::policy define', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  shared_pp = <<-eos
    class { 'xtreemfs::settings':
      dir_host => 'localhost',
    }
    include xtreemfs::role::directory
    include xtreemfs::role::metadata
    include xtreemfs::role::storage

    xtreemfs::volume { 'myVolume': }
    xtreemfs::mount { '/mnt/xtreemfs-myvolume':
      ensure => 'mounted',
      volume => 'myVolume',
    }
    file { '/mnt/xtreemfs-myvolume/dir1':
      ensure  => 'directory',
      require => Xtreemfs::Mount['/mnt/xtreemfs-myvolume'],
    }
    eos

  describe 'policy as one server as WqRq with factor == 1' do
    pp = <<-eos
    #{shared_pp}
    xtreemfs::policy { '/mnt/xtreemfs-myvolume/dir1':
      policy  => 'WqRq',
      factor  => 1,
    }
    eos
    
    it 'should not work' do
      apply_manifest(pp, :expect_failures => true)
    end
  end

  describe 'policy as one server as WqRq' do
    pp = <<-eos
    #{shared_pp}
    xtreemfs::policy { '/mnt/xtreemfs-myvolume/dir1':
      policy  => 'WqRq',
      factor  => 2,
    }
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :expect_changes => false)
    end
  end

  describe 'policy an one server as WqRq with explicit require' do
    pp = <<-eos
    #{shared_pp}
    xtreemfs::policy { '/mnt/xtreemfs-myvolume/dir1':
      policy  => 'WaR1',
      factor  => 2,
      require => File['/mnt/xtreemfs-myvolume/dir1'],
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