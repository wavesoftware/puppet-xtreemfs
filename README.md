xtreemfs
========

##### Status Info
[![GitHub Issues](https://img.shields.io/github/issues/wavesoftware/puppet-xtreemfs.svg)](https://github.com/wavesoftware/puppet-xtreemfs/issues)  [![Puppet Forge](https://img.shields.io/puppetforge/v/wavesoftware/xtreemfs.svg)](https://forge.puppetlabs.com/wavesoftware/xtreemfs) [![GitHub Release](https://img.shields.io/github/release/wavesoftware/puppet-xtreemfs.svg)](https://github.com/wavesoftware/puppet-xtreemfs/releases) [![Apache 2.0 License](http://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://raw.githubusercontent.com/wavesoftware/puppet-xtreemfs/develop/LICENSE)

##### Master (stable) branch
[![Build Status](https://img.shields.io/travis/wavesoftware/puppet-xtreemfs/master.svg)](https://travis-ci.org/wavesoftware/puppet-xtreemfs) [![Build Status](http://jenkins-ro.wavesoftware.pl/buildStatus/icon?job=puppet-xtreemfs-acceptace-centos65-stable)](http://jenkins-ro.wavesoftware.pl/job/puppet-xtreemfs-acceptace-centos65-stable/) [![Coverage Status](https://img.shields.io/coveralls/wavesoftware/puppet-xtreemfs/master.svg)](https://coveralls.io/r/wavesoftware/puppet-xtreemfs?branch=master) [![Code Climate](https://codeclimate.com/github/wavesoftware/puppet-xtreemfs/badges/gpa.svg?branch=master)](https://codeclimate.com/github/wavesoftware/puppet-xtreemfs) [![Inline docs](http://inch-ci.org/github/wavesoftware/puppet-xtreemfs.svg?branch=master)](http://inch-ci.org/github/wavesoftware/puppet-xtreemfs)

##### Development branch
[![Build Status](https://img.shields.io/travis/wavesoftware/puppet-xtreemfs/develop.svg)](https://travis-ci.org/wavesoftware/puppet-xtreemfs) [![Build Status](http://jenkins-ro.wavesoftware.pl/buildStatus/icon?job=puppet-xtreemfs-acceptace-centos65)](http://jenkins-ro.wavesoftware.pl/job/puppet-xtreemfs-acceptace-centos65/) [![Dependency Status](https://gemnasium.com/wavesoftware/puppet-xtreemfs.svg)](https://gemnasium.com/wavesoftware/puppet-xtreemfs) [![Coverage Status](https://img.shields.io/coveralls/wavesoftware/puppet-xtreemfs/develop.svg)](https://coveralls.io/r/wavesoftware/puppet-xtreemfs?branch=develop) [![Code Climate](https://codeclimate.com/github/wavesoftware/puppet-xtreemfs/badges/gpa.svg?branch=develop)](https://codeclimate.com/github/wavesoftware/puppet-xtreemfs) [![Inline docs](http://inch-ci.org/github/wavesoftware/puppet-xtreemfs.svg?branch=develop)](http://inch-ci.org/github/wavesoftware/puppet-xtreemfs) 

Table of Contents
-----------------

1. [Overview - What is the XtreemFS module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with XtreemFS module](#setup)
    * [Configuring the installation](#configuring-the-installation) 
4. [Usage - How to use the module for various tasks](#usage)
    * [Creating a volume](#creating-a-volume) 
    * [Managing mounts](#managing-mounts)
    * [Replication](#replication)
    * [Automatic replication](#automatic-replication)
5. [Tests - how to perform unit and acceptance tests](#tests)
6. [Contributing - how to send your work?](#contributing)


Overview
--------

The XtreemFS module allows you to easily manage XtreemFS installation, volumes and mounts with Puppet.

Module Description
-------------------

XtreemFS is a fault-tolerant distributed file system for all storage needs. The xtreemfs module allows you to manage XtreemFS packages and services on several operating systems, while also supporting basic management of XtreemFS volumes and mounts. The module offers support for basic management of replication settings.

Setup
-----

**What wavesoftware/xtreemfs affects:**

* package/service/configuration files for XtreemFS
* listened-to ports


###Configuring the installation

The main configuration you'll need to do will be around the `xtreemfs::role::directory`, `xtreemfs::role::metadata` and `xtreemfs::role::storage` classes. The default parameters are reasonable. 

####To manage a XtreemFS with sane defaults on one server:

```puppet
include xtreemfs::role::directory
include xtreemfs::role::metadata
include xtreemfs::role::storage
```

####Hiera configuration

 - `xtreemfs::settings::dir_host`
     - Provide an host to where metadata and storage nodes will be connecting, defaults: `$::fqdn`
 - `xtreemfs::settings::dir_port`
     - A port for directory service connection
 - `xtreemfs::settings::dir_protocol`
     - A protocol for directory service connection
 - `xtreemfs::settings::object_dir`
     - A direcory where storage nodes will hold their replicated data. Good idea is to provide a directory on secure RAID drive, defaults: `/var/lib/xtreemfs`
 - `xtreemfs::settings::install_packages`
     - If set to `true` will install packages of XtreemFS, defaults: `true`di
 - `xtreemfs::settings::add_repo`
     - If set to `true` will add to system repository for XtreemFS, defaults: `true`
 - `xtreemfs::settings::properties`
     - A properties hash to provide configuration options in form exactly like: http://www.xtreemfs.org/xtfs-guide-1.5/index.html#tth_sEc3.2.6    
 

####For distributed without hiera

Directory service

```puppet
# In this example fqdn is dir.vagrant.dev
include xtreemfs::role::directory
```

Metadata server

```puppet
class { 'xtreemfs::role::metadata':
  dir_host => 'dir.vagrant.dev',
}
```

Storage node(s)

```puppet
class { 'xtreemfs::role::storage':
  dir_host   => 'dir.vagrant.dev',
  object_dir => '/mnt/sdb1/xtreem', # actual object will be in: /mnt/sdb1/xtreem/objs 
}
```

Client(s)

Described in usage section.


Usage
-----

###Creating a volume

There are many ways to set up a XtreemFS volume using the `xtreemfs::volume` definition. For instance, to set up simple volume on default parameters:

```puppet
xtreemfs::volume { 'myVolume':
  ensure   => 'present',
  dir_host => 'dir.vagrant.dev',
}
```
In this example, you would create volume with default parameters.

###Managing mounts

To manage mount point:

```puppet
xtreemfs::mount { '/mnt/xtreemfs':
  ensure   => 'mounted',
  volume   => 'myVolume',
  dir_host => 'dir.vagrant.dev',
}
```

In this example, you would mount an existing volume into `/mnt/xtreemfs` directory that already exists.

###Replication

To replicate an existing file for ex.: `/mnt/xtreemfs/centos7.iso` inside the XtreemFS mount point, use:

```puppet
xtreemfs::replicate { '/mnt/xtreemfs/centos7.iso':
  policy  => 'WqRq',
  factor  => 2,      # Required storage nodes
}
```

###Automatic replication

To automatically replicate new files in XtreemFS mount point you can set a policy for directory. This will not affect existing files. Take a look at example usage:

```puppet
xtreemfs::policy { '/mnt/xtreemfs':
  policy  => 'WqRq',
  factor  => 2,      # Required storage nodes
}
```

### Tests

There are two types of tests distributed with the module. Unit tests with rspec-puppet and system tests using rspec-system.

For unit testing, make sure you have:

* rake
* bundler

Install the necessary gems (gems will be downloaded to private `.vendor` directory):

```shell
bundle install --path .vendor
```

And then run the unit tests:

```shell
bundle exec rake spec
```

The unit tests are ran in Travis-CI as well, if you want to see the results of your own tests register the service hook through Travis-CI via the accounts section for your Github clone of this project.

If you want to run the system acceptance tests, make sure you also have:

* vagrant > 1.2.x
* Virtualbox > 4.2.10

Then run the tests using:

```shell
bundle exec rake acceptance
```

To run the tests on different operating system, see the sets available in `spec/acceptance/nodesets/` and run the specific set with the following syntax:

```shell
bundle exec rake acceptance RS_SET=debian-76-x64
```

You can also run system acceptance tests against Docker containers. If you want to do this, make sure you also have:

* docker > 1.0.0

To run the the test on docker container use:

```shell
bundle exec rake acceptance RS_SET=centos-65-x64-docker
```

###Contributing

Contributions are welcome!

To contribute, follow the standard [git flow](http://danielkummer.github.io/git-flow-cheatsheet/) of:

1. Fork it
1. Create your feature branch (`git checkout -b feature/my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin feature/my-new-feature`)
1. Create new Pull Request

Even if you can't contribute code, if you have an idea for an improvement please open an [issue](https://github.com/wavesoftware/xtreemfs/issues).
