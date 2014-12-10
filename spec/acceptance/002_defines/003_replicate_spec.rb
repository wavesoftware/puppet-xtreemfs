require 'spec_helper_acceptance'

describe 'xtreemfs::replicate define', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

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
    file { '/mnt/xtreemfs-myvolume/file1':
      ensure  => 'file',
      content => 'a file1 content',
      require => Xtreemfs::Mount['/mnt/xtreemfs-myvolume'],
    }
    eos

  describe 'replicate on one server as WqRq' do
    pp = <<-eos
    #{shared_pp}
    xtreemfs::replicate { '/mnt/xtreemfs-myvolume/file1':
      policy  => 'WqRq',
      factor  => 1,
    }
    eos
    
    it 'should work without errors' do
      apply_manifest(pp, :catch_failures => true)
    end
    it 'should not make any changes when executed twice' do
      apply_manifest(pp, :expect_changes => false)
    end
  end

  describe 'replicate on one server as WqRq with explicit require' do
    pp = <<-eos
    #{shared_pp}
    xtreemfs::replicate { '/mnt/xtreemfs-myvolume/file1':
      policy  => 'none',
      factor  => 1,
      require => File['/mnt/xtreemfs-myvolume/file1'],
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