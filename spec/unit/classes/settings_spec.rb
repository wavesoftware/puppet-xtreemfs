require 'spec_helper'

describe 'xtreemfs::settings', :type => :class do
  let :facts do
    {
      :operatingsystem        => 'Debian',
      :operatingsystemrelease => '6.0',
      :fqdn                   => 'somehost.localdomain',
    }
  end
  it { should compile.with_all_deps }
  it do
    should contain_class("xtreemfs::settings").with(
      'dir_host'         => 'somehost.localdomain',
      'object_dir'       => '/var/lib/xtreemfs',
      'install_packages' => true,
      'add_repo'         => true,
      'properties'       => {}
    )
  end
  it { should contain_class("xtreemfs::internal::settings") }
end
