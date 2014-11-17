require 'spec_helper'

describe 'xtreemfs::role::storage', :type => :class do
  context 'in Debian wheezy' do
    let :facts do
      {
        :operatingsystem           => 'Debian',
        :lsbdistid                 => 'Debian',
        :lsbdistcodename           => 'wheezy',
        :osfamily                  => 'Debian',
        :operatingsystemmajrelease => '7',
        :operatingsystemrelease    => '7.0',
        :fqdn                      => 'storage.localdomain',
      }
    end
    it { should compile }
    it { should contain_package('xtreemfs-server') }
    it { should contain_anchor('xtreemfs::repo') }
    it { should contain_exec('apt_update').that_comes_before('Anchor[xtreemfs::repo]') }
    it do
      should contain_apt__source('xtreemfs').with(
        'ensure'     => 'present',
        'location'   => 'http://download.opensuse.org/repositories/home:/xtreemfs/Debian_7.0',
        'repos'      => './',
        'key_source' => 'http://download.opensuse.org/repositories/home:/xtreemfs/Debian_7.0/Release.key',
      )
    end
    it do
      should contain_service('xtreemfs-osd').with(
        'ensure'     => 'running',
        'enable'     => true,
        'hasrestart' => true,
        'hasstatus'  => true,
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
    context 'with params specified: object_dir => "/mnt/sdb1"' do
      let :params do
        { :object_dir => '/mnt/sdb1' }
      end
      it do
        should contain_augeas('xtreemfs::configure::osd').with(
          'context' => '/files/etc/xos/xtreemfs/osdconfig.properties',
          'changes' => [ 
            'set dir_service.host storage.localdomain',
            'set object_dir /mnt/sdb1/objs' 
          ],
        )
      end
      it do
        should contain_file('/mnt/sdb1').with(
          'ensure' => 'directory',
          'owner'  => 'xtreemfs',
          'group'  => 'xtreemfs'
        ).that_comes_before 'Anchor[xtreemfs::packages]'
      end
      it 'should contain directory /mnt/sdb1 that notifies Anchor[xtreemfs::configure]' do
        should contain_file('/mnt/sdb1').that_notifies 'Anchor[xtreemfs::configure]'
      end
    end
    context 'with params specified: dir_service => "dir.example.vm"' do
      let :params do
        { :dir_service => 'dir.example.vm' }
      end
      it do 
        should contain_class('xtreemfs::internal::configure::storage')
          .with( 'dir_service' => 'dir.example.vm' )
      end
      it { should contain_augeas('xtreemfs::configure::osd').with(
        'context' => '/files/etc/xos/xtreemfs/osdconfig.properties',
        'changes' => [ 
          'set dir_service.host dir.example.vm',
          'set object_dir /var/lib/xtreemfs/objs' 
        ],
      ) }
      it 'should contains augeas[..::osd] that comes before Anchor[..::packages]' do
        should contain_augeas('xtreemfs::configure::osd')
          .that_comes_before('Anchor[xtreemfs::packages]')
      end
      it 'should contains augeas[..::osd] that notifies Anchor[..::configure]' do
        should contain_augeas('xtreemfs::configure::osd')
          .that_notifies('Anchor[xtreemfs::configure]')
      end
    end
    context 'with default params' do
      it do 
        should contain_class('xtreemfs::internal::configure::storage')
          .with( 'dir_service' => 'storage.localdomain' )
      end
    end
  end
  context 'in OracleLinux 6.5' do
    let :facts do
      {
        :operatingsystem           => 'OracleLinux',
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => '6',
        :operatingsystemrelease    => '6.5',
        :fqdn                      => 'storage.localdomain',
      }
    end
    it { should compile }
    it { should contain_package('xtreemfs-server') }
    it { should_not contain_exec('apt_update') }
    it { should_not contain_apt__source('xtreemfs') }
    it { should contain_anchor('xtreemfs::repo') }
    it do
      should contain_yumrepo('xtreemfs').with(
        'ensure'   => 'present',
        'baseurl'  => 'http://download.opensuse.org/repositories/home:/xtreemfs/CentOS_6',
        'gpgcheck' => true,
        'gpgkey'   => "http://download.opensuse.org/repositories/home:/xtreemfs/CentOS_6/repodata/repomd.xml.key",
      ).that_comes_before('Anchor[xtreemfs::repo]')
    end
    it do
      should contain_service('xtreemfs-osd').with(
        'ensure'     => 'running',
        'enable'     => true,
        'hasrestart' => true,
        'hasstatus'  => true,
      )
    end
  end
end
