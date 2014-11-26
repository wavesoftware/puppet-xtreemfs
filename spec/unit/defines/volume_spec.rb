require 'spec_helper'

describe 'xtreemfs::volume', :type => :define do
  let :facts do
    {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => '6.0',
      :fqdn                   => 'slave4.vm',
    }
  end

  let :title do
    'myVolume'
  end

  describe 'should work with only default parameters' do
    it do
      should contain_xtreemfs__volume('myVolume').with(
        'ensure'      => 'present',
        'dir_service' => nil,
        'options'     => {}
      )
    end
    it do
      should contain_xtreemfs_volume('myVolume').with(
        'ensure'      => 'present',
        'host'        => 'slave4.vm',
        'options'     => {}
      )
    end
  end

  describe 'should work with all parameters' do
    let :params do
      {
        :ensure      => 'absent',
        :dir_service => 'dir-service.example.org',
        :options     => {
          '--pem-certificate-file-path' => '/etc/ssl/certs/slave1-crt.pem',
          '--pem-private-key-file-path' => '/etc/ssl/private/slave1-key.pem',
        },
      }
    end
    it do
      should contain_xtreemfs_volume('myVolume').with(
        'ensure'  => 'absent',
        'host'    => 'dir-service.example.org',
        'options' => {
          '--pem-certificate-file-path' => '/etc/ssl/certs/slave1-crt.pem',
          '--pem-private-key-file-path' => '/etc/ssl/private/slave1-key.pem',
        }
      )
    end
  end
end