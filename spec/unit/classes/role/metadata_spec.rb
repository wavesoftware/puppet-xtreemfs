require 'spec_helper'

describe 'xtreemfs::role::metadata', :type => :class do
  context 'in Ubuntu precise' do
    let :facts do
      {
        :operatingsystem           => 'Ubuntu',
        :lsbdistid                 => 'Ubuntu',
        :lsbdistcodename           => 'precise',
        :osfamily                  => 'Debian',
        :operatingsystemrelease    => '12.04',
        :fqdn                      => 'somehost.localdomain'
      }
    end
    it { should compile.with_all_deps }
    it { should contain_class('xtreemfs::role::metadata') }
    it { should contain_package('xtreemfs-server') }
    it { should contain_anchor('xtreemfs::repo') }
    it { should contain_exec('apt_update').that_comes_before('Anchor[xtreemfs::repo]') }
    it do
      should contain_apt__source('xtreemfs').with(
        'ensure'     => 'present',
        'location'   => 'http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_12.04',
        'repos'      => './',
        'release'    => '',
        'key_source' => 'http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_12.04/Release.key'
      )
    end
    it do
      should contain_service('xtreemfs-mrc').with(
        'ensure'     => 'running',
        'enable'     => true,
        'hasrestart' => true,
        'hasstatus'  => true
      )
    end
    context 'with params specified: install_packages => false' do
      let :params do
        { :install_packages => false }
      end
      it { should compile }
    end
    context 'with params specified: add_repo => false' do
      let :params do
        { :add_repo => false }
      end
      it { should compile }
    end
    context 'with params specified: dir_service => "dir.example.vm"' do
      let :params do
        { :dir_host => 'dir.example.vm' }
      end
      it do 
        should contain_class('xtreemfs::internal::configure::metadata').with( 
          'dir_service' => 'dir.example.vm'
        )
      end
      it { should contain_augeas('xtreemfs::configure::mrc').with(
        'context' => '/files/etc/xos/xtreemfs/mrcconfig.properties',
        'changes' => 'set dir_service.host dir.example.vm'
      ) }
      it 'should contains augeas[..::mrc] that comes before Anchor[..::packages]' do
        should contain_augeas('xtreemfs::configure::mrc').that_requires('Anchor[xtreemfs::packages]')
      end
      it 'should contains augeas[..::mrc] that notifies Anchor[..::configure]' do
        should contain_augeas('xtreemfs::configure::mrc').that_notifies('Anchor[xtreemfs::configure]')
      end
    end
    context 'with default params' do
      it do 
        should contain_class('xtreemfs::internal::configure::metadata').with( 
          'dir_service' => 'somehost.localdomain'
        )
      end
    end
  end
  context 'in CentOS 6.4' do
    let :facts do
      {
        :operatingsystem           => 'CentOS',
        :osfamily                  => 'RedHat',
        :operatingsystemrelease    => '6.4',
        :fqdn                      => 'somehost.localdomain'
      }
    end
    it { should compile.with_all_deps }
    it { should contain_package('xtreemfs-server') }
    it { should_not contain_exec('apt_update') }
    it { should_not contain_apt__source('xtreemfs') }
    it { should contain_anchor('xtreemfs::repo') }
    it do
      should contain_yumrepo('xtreemfs').with(
        'baseurl'  => 'http://download.opensuse.org/repositories/home:/xtreemfs/CentOS_6',
        'gpgcheck' => 1,
        'enabled'  => 1,
        'gpgkey'   => "http://download.opensuse.org/repositories/home:/xtreemfs/CentOS_6/repodata/repomd.xml.key"
      ).that_comes_before('Anchor[xtreemfs::repo]')
    end
    it do
      should contain_service('xtreemfs-mrc').with(
        'ensure'     => 'running',
        'enable'     => true,
        'hasrestart' => true,
        'hasstatus'  => true
      )
    end
  end
end
