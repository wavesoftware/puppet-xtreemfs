require 'spec_helper'

describe 'xtreemfs::settings', :type => :class do
  let :facts do
    {
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => 6,
      :fqdn                   => 'somehost.localdomain',
    }
  end
  it { should compile }
  it do
    should contain_class("xtreemfs::settings").with(
      'dir_service'      => 'somehost.localdomain',
      'object_dir'       => '/var/lib/xtreemfs',
      'install_packages' => true,
      'add_repo'         => true,
      'extra'            => {},
    )
  end
  it { should contain_class("xtreemfs::internal::settings") }
end
