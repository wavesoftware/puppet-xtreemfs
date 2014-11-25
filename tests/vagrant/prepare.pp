package { 'librarian-puppet': 
  ensure   => 'installed',
  provider => 'gem',
  require  => Package['ruby-dev'],
}
package { ['git', 'ruby-dev']:
  ensure => 'installed',
}

exec { 'librarian-puppet config path /etc/puppet/modules --global && librarian-puppet update --verbose && touch .tmp/modules-installed':
  path      => $::path,
	cwd       => '/etc/puppet/modules/xtreemfs',
  onlyif    => 'bash -c \'[[ ! -f .tmp/modules-installed ]] || [[ metadata.json -nt .tmp/modules-installed ]]\'',
  logoutput => true,
  require   => [
    Package['librarian-puppet'],
    Package['git'],
  ],
}

augeas { '/etc/puppet/puppet.conf':
  context => '/files/etc/puppet/puppet.conf',
  changes => [
    'rm main/templatedir',
    'set main/show_diff true'
  ],
}