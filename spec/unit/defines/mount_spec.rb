require 'spec_helper'

describe 'xtreemfs::mount', :type => :define do
  let :facts do
    {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'CentOS',
      :operatingsystemrelease => '6.6',
      :fqdn                   => 'slave1.vm'
    }
  end

  let :title do
    '/mnt/my-xtreemfs-mount'
  end

  describe 'shouldn\'t work with only default parameters, must pass a volume' do
    it do
      expect { should compile }.
        to raise_error(/Must pass volume to Xtreemfs::Mount/)
    end
  end

  describe 'should work with only volume passed' do
    let :params do
      {
        :volume      => 'myVolume'
      }
    end
    it { should compile }
    it { should contain_class('xtreemfs::internal::packages::client') }
    it do
      should contain_xtreemfs__mount('/mnt/my-xtreemfs-mount').with(
        'ensure'      => 'mounted',
        'volume'      => 'myVolume',
        'dir_host'    => nil,
        'atboot'      => false,
        'options'     => 'defaults,allow_other'
      )
    end
    it { should contain_file('/mnt/my-xtreemfs-mount').with('ensure' => 'directory') }
    it do
      should contain_mount('/mnt/my-xtreemfs-mount').with(
        'ensure'      => 'mounted',
        'device'      => 'slave1.vm/myVolume',
        'fstype'      => 'xtreemfs',
        'atboot'      => false,
        'options'     => 'defaults,allow_other'
      ).that_requires('Anchor[xtreemfs::service]')
    end
  end
end