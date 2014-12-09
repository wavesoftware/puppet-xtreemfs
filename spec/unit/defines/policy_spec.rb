require 'spec_helper'

describe 'xtreemfs::policy', :type => :define do
  let :facts do
    {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'CentOS',
      :operatingsystemrelease => '6.6',
      :fqdn                   => 'slave6.vm',
    }
  end

  let :title do
    '/mnt/xtfs/a-directory-1'
  end

  describe 'should work with only default parameters' do
    it { should compile }
    it { should contain_package('xtreemfs-client') }
    it { should contain_package('xtreemfs-tools') }
    it do
      should contain_xtreemfs__policy('/mnt/xtfs/a-directory-1').with(
        'policy'    => 'none',
        'factor'    => 1
      )
    end
    it do
      should contain_xtreemfs_policy('/mnt/xtfs/a-directory-1').with(
        'policy'    => 'none',
        'factor'    => 1
      ).that_requires('Anchor[xtreemfs::packages]')
    end
  end

  describe 'should work with given parameters' do
    let :params do
      {
        :policy  => 'quorum',
        :factor  => 5
      }
    end
    it { should compile }
    it { should contain_package('xtreemfs-client') }
    it { should contain_package('xtreemfs-tools') }
    it do
      should contain_xtreemfs__policy('/mnt/xtfs/a-directory-1').with(
        'policy'    => 'quorum',
        'factor'    => 5
      )
    end
    it do
      should contain_xtreemfs_policy('/mnt/xtfs/a-directory-1').with(
        'policy'    => 'quorum',
        'factor'    => 5
      )
    end
  end

end
