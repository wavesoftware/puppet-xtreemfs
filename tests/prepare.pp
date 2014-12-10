package { 'librarian-puppet':
  ensure   => 'installed',
  provider => 'gem',
  require  => Package['ruby-dev'],
}
package { ['git', 'ruby-dev']:
  ensure => 'installed',
}

$lock = "tests/.vagrant/machines/${::hostname}/virtualbox/modules-installed"

exec { 'librarian-puppet':
  command   => "librarian-puppet config path /etc/puppet/modules --global && librarian-puppet update --verbose && touch ${lock}",
  path      => $::path,
  cwd       => '/etc/puppet/modules/xtreemfs',
  onlyif    => "bash -c '[[ ! -f ${lock} ]] || [[ metadata.json -nt ${lock} ]]'",
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