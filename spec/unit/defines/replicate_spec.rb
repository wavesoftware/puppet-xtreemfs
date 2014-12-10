require 'spec_helper'

describe 'xtreemfs::replicate', :type => :define do
  let :facts do
    {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'OracleLinux',
      :operatingsystemrelease => '6.5',
      :fqdn                   => 'slave2.vm',
    }
  end

  let :title do
    '/mnt/xtfs/a-file-1'
  end

  describe 'should work with only default parameters' do
    it { should compile }
    it { should contain_package('xtreemfs-client') }
    it { should contain_package('xtreemfs-tools') }
    it do
      should contain_xtreemfs__replicate('/mnt/xtfs/a-file-1').with(
        'policy'    => 'none',
        'factor'    => 1
      )
    end
    it do
      should contain_xtreemfs_replicate('/mnt/xtfs/a-file-1').with(
        'policy'    => 'none',
        'factor'    => 1
      ).that_requires('Anchor[xtreemfs::packages]')
    end
  end

  describe 'should work with all parameters' do
    let :params do
      {
        :policy  => 'WqRq',
        :factor  => 2
      }
    end
    it do
      should contain_xtreemfs_replicate('/mnt/xtfs/a-file-1').with(
        'policy'    => 'WqRq',
        'factor'    => 2
      )
    end
  end

  describe 'should validate invalid policy' do
    context 'policy that equals WqRq' do
      let :params do 
        { :policy => 'WqRq' }
      end
      it { should compile }
    end
    context 'policy that equals quorum' do
      let :params do 
        { :policy => 'quorum' }
      end
      it { should compile }
    end
    context 'policy that equals qazwsxedc' do
      let :params do 
        { :policy => 'qazwsxedc' }
      end
      it 'should not compile' do
        expect { should compile }.to raise_error
      end
    end
  end
  describe 'should validate invalid factor' do
    context 'factor that equals 0' do
      let :params do 
        { :factor => 0 }
      end
      it 'should not compile' do
        expect { should compile }.to raise_error
      end
    end
    context 'factor that equals -2' do
      let :params do 
        { :factor => -2 }
      end
      it 'should not compile' do
        expect { should compile }.to raise_error
      end
    end
    context 'factor that equals qaz' do
      let :params do 
        { :factor => 'qaz' }
      end
      it 'should not compile' do
        expect { should compile }.to raise_error
      end
    end
  end
end