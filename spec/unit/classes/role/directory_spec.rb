require 'spec_helper'

describe 'xtreemfs::role::directory', :type => :class do
  context 'in Ubuntu trusty' do
    let :facts do
      {
        :operatingsystem           => 'Ubuntu',
        :lsbdistid                 => 'Ubuntu',
        :lsbdistcodename           => 'trusty',
        :osfamily                  => 'Debian',
        :operatingsystemrelease    => '14.04',
        :fqdn                      => 'somehost.localdomain',
      }
    end
    it { should compile.with_all_deps }
    it { should contain_anchor('xtreemfs::configure') }
    it { should contain_anchor('xtreemfs::end') }
    it { should contain_anchor('xtreemfs::packages') }
    it { should contain_anchor('xtreemfs::service') }
    it { should contain_augeas('xtreemfs::configure::directory') }
    it { should contain_class('xtreemfs::role::directory') }
    it { should contain_class('xtreemfs::internal::workflow') }
    it { should contain_class('xtreemfs::internal::repo') }
    it { should contain_class('xtreemfs::internal::packages::server') }
    it { should contain_class('xtreemfs::internal::configure::directory') }
    it { should contain_package('xtreemfs-server') }
    it { should contain_anchor('xtreemfs::repo') }
    it { should contain_exec('apt_update').that_comes_before('Anchor[xtreemfs::repo]') }
    it do
      should contain_apt__source('xtreemfs').with(
        'ensure'     => 'present',
        'location'   => 'http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_14.04',
        'repos'      => './',
        'release'    => '',
        'key_source' => 'http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_14.04/Release.key'
      )
    end
    it do
      should contain_service('xtreemfs-dir').with(
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

    context 'double checking for apt module resources' do
      it { should contain_class('apt') }
      it { should contain_class('apt::update') }
      it { should contain_class('apt::params') }
      it { should contain_anchor('apt_key 07D6EA4F2FA7E736 present') }
      it { should contain_anchor('apt::source::xtreemfs') }
      it { should contain_anchor('apt::update') }
      
      # Dodgy deps :-/
      it { should contain_file('xtreemfs.list') }
      it { should contain_file('sources.list.d') }
      it { should contain_file('sources.list') }
      it { should contain_file('preferences.d') }

      # Even dodgier deps :-(
      it { should contain_file('01proxy') }
      it { should contain_file('/etc/apt/apt.conf.d/15update-stamp') }
      it { should contain_file('old-proxy-file') }
    end
  end
  context 'in CentOS 7' do
    let :facts do
      {
        :operatingsystem           => 'CentOS',
        :osfamily                  => 'RedHat',
        :operatingsystemrelease    => '7.0.1406',
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
        'baseurl'  => 'http://download.opensuse.org/repositories/home:/xtreemfs/CentOS_7',
        'gpgcheck' => 1,
        'enabled'  => 1,
        'gpgkey'   => "http://download.opensuse.org/repositories/home:/xtreemfs/CentOS_7/repodata/repomd.xml.key"
      ).that_comes_before('Anchor[xtreemfs::repo]')
    end
    it do
      should contain_service('xtreemfs-dir').with(
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
  end
end
