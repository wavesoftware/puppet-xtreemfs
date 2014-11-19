require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

class String
  # Provide ability to remove indentation from strings, for the purpose of
  # left justifying heredoc blocks.
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end

def shellescape(str)
  str = str.to_s

  # An empty argument will be skipped, so return empty quotes.
  return "''" if str.empty?

  str = str.dup

  # Treat multibyte characters as is.  It is caller's responsibility
  # to encode the string in the right encoding for the shell
  # environment.
  str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")

  # A LF cannot be escaped with a backslash because a backslash + LF
  # combo is regarded as line continuation and simply ignored.
  str.gsub!(/\n/, "'\n'")

  return str
end

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'

  # This will install the latest available package on el and deb based
  # systems fail on windows and osx, and install via gem on other *nixes
  foss_opts = { :default_action => 'gem_install' }
  if default.is_pe?; then install_pe; else install_puppet( foss_opts ); end

  hosts.each do |host|
    shell("mkdir -p #{host['distmoduledir']}")
    if ! host.is_pe?
      # Augeas is only used in one place, for Redhat.
      if fact('osfamily') == 'RedHat'
        install_package host, 'ruby-devel'
        #install_package host, 'augeas-devel'
        #install_package host, 'ruby-augeas'
      end
    end
  end
end

UNSUPPORTED_PLATFORMS = ['AIX','windows','Solaris', 'Suse']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'xtreemfs')

    # Set up selinux if appropriate.
    if fact('osfamily') == 'RedHat' && fact('selinux') == 'true'
      pp = <<-EOS
        if $::osfamily == 'RedHat' and $::selinux == 'true' {

        }
      EOS

      apply_manifest_on(agents, pp, :catch_failures => false)
    end

    hosts.each do |host|
      on host, "/bin/touch #{default['puppetpath']}/hiera.yaml"
      on host, 'chmod 755 /root'
      if fact('osfamily') == 'Debian'
        on host, "echo \"en_US ISO-8859-1\nen_US.UTF-8 UTF-8\n\" > /etc/locale.gen"
        on host, '/usr/sbin/locale-gen'
        on host, '/usr/sbin/update-locale'
      end

      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
    end


  end
end
