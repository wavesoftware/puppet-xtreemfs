require 'spec_helper_acceptance'

describe 'xtreemfs::mount define', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  describe 'fail without volume' do
    pp = <<-eos
    class { 'xtreemfs::settings':
      dir_host => 'localhost',
    }
    include xtreemfs::role::directory
    include xtreemfs::role::metadata
    include xtreemfs::role::storage

    xtreemfs::volume { 'myVolume': }
    xtreemfs::mount { '/mnt/xtreemfs-myvolume': }
    eos
    
    it 'shouldn\'t work becouse of errors' do
      apply_manifest(pp, :expect_failures => true)
    end
  end

  describe 'creating with default params' do
    
    pp = <<-eos
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
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :expect_changes => false)
    end
    it 'should be mounted' do
      shell 'mount | grep /mnt/xtreemfs-myvolume'
    end
    it 'should be possible to add files' do
      shell 'echo "This will be saved!" > /mnt/xtreemfs-myvolume/file1.txt'
      shell '[ -f /mnt/xtreemfs-myvolume/file1.txt ] && grep "This will be saved!" /mnt/xtreemfs-myvolume/file1.txt'
    end
    it 'should be possible to remove files' do
      shell 'rm /mnt/xtreemfs-myvolume/file1.txt'
      shell '[ ! -f /mnt/xtreemfs-myvolume/file1.txt ]'
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

    xtreemfs::volume { 'myVolume': }
    xtreemfs::mount { '/mnt/xtreemfs-myvolume': 
      ensure => 'absent',
      volume => 'myVolume',
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