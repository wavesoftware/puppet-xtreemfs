require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'

  hosts.each do |host|
    install_package host, 'wget'
  end

  puppetver = if RUBY_VERSION < '1.9.0' then '2.7.26' else ENV['PUPPET_VERSION'] end
  facterver = ENV['FACTER_VERSION']
  # This will install the latest available package on el and deb based
  # systems fail on windows and osx, and install via gem on other *nixes
  foss_opts = { :default_action => 'gem_install' }
  foss_opts[:version]        = puppetver unless puppetver.nil?
  foss_opts[:facter_version] = facterver unless facterver.nil?

  if default.is_pe?
    install_pe
  else 
    install_puppet foss_opts
  end

  hosts.each do |host|
    shell("mkdir -p #{host['distmoduledir']}")
  end
end

UNSUPPORTED_PLATFORMS = ['AIX','windows','Solaris', 'Suse']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    install_dev_puppet_module(:source => proj_root, :module_name => 'xtreemfs')

    hosts.each do |host|
      on host, "/bin/touch #{default['puppetpath']}/hiera.yaml"
      on host, 'chmod 755 /root'
      if fact('osfamily') == 'Debian'
        install_package host, 'locales'
        on host, "echo \"en_US ISO-8859-1\nen_US.UTF-8 UTF-8\n\" > /etc/locale.gen"
        on host, '/usr/sbin/locale-gen'
        on host, '/usr/sbin/update-locale'
      end

      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
    end

  end
end
