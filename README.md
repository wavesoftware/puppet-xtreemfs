xtreemfs
========

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

The main configuration you'll need to do will be around the `xtreemfs::server::directory`, `xtreemfs::server::metadata` and `xtreemfs::server::storage` classes. The default parameters are reasonable. 

####To manage a XtreemFS with sane defaults on one server:

```puppet
include xtreemfs::server::directory
include xtreemfs::server::metadata
include xtreemfs::server::storage
```

####For a more customized configuration (on 4+ nodes)

Directory service

```puppet
# In this example fqdn is dir.vagrant.dev
include xtreemfs::server::directory
```

Metadata server

```puppet
class { 'xtreemfs::server::metadata':
  dir_service => 'dir.vagrant.dev',
}
```

Storage node(s)

```puppet
class { 'xtreemfs::server::storage':
  dir_service => 'dir.vagrant.dev',
  object_dir  => '/mnt/sdb1/objs',
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
  ensure      => 'present',
  dir_service => 'dir.vagrant.dev',
}
```
In this example, you would create volume with default parameters.

###Managing mounts

To manage mount point:

```puppet
xtreemfs::mount { '/mnt/xtreemfs':
  ensure => 'present',
  volume => 'dir.vagrant.dev/myVolume',
}
```

In this example, you would mount an existing volume into `/mnt/xtreemfs` directory that already exists.

###Replication

To replicate an existing file for ex.: `/mnt/xtreemfs/centos7.iso` inside the XtreemFS mount point, use:

```puppet
xtreemfs::replicate { '/mnt/xtreemfs/centos7.iso':
  policy => 'WqRq',
}
```

Recurse:

```puppet
xtreemfs::replicate { '/mnt/xtreemfs/shared-dir':
  policy  => 'WqRq',
  recurse => true,
}
```

###Automatic replication

To automaticy replicate ne files in XtreemFS mount point (existing files are not affected):

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

Install the necessary gems:

```shell
bundle install --path=vendor
```

And then run the unit tests:

```shell
bundle exec rake spec
```

The unit tests are ran in Travis-CI as well, if you want to see the results of your own tests register the service hook through Travis-CI via the accounts section for your Github clone of this project.

If you want to run the system tests, make sure you also have:

* vagrant > 1.2.x
* Virtualbox > 4.2.10

Then run the tests using:

```shell
bundle exec rspec spec/acceptance
```

To run the tests on different operating systems, see the sets available in .nodeset.yml and run the specific set with the following syntax:

```shell
RSPEC_SET=debian-607-x64 bundle exec rspec spec/acceptance
```
