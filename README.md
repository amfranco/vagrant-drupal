# Drupal Vagrant

  A chef-based project template provides easy to configure, reproducible, and portable work environments for drupal development.

*Server stack:*

* nginx
* varnish
* apache2
* php
* mysql
* solr
* nodejs

for more info about server stack [see image](http://www.unixguru.co.uk/wp-content/uploads/2013/02/UnixGuruNVAColour1.png)

Tested on CentOS 64 and Ubuntu 32/64

-------------

## Vagrant

* Website: [http://www.vagrantup.com](http://www.vagrantup.com)
* Source: [https://github.com/mitchellh/vagrant](https://github.com/mitchellh/vagrant)
* IRC: `#vagrant` on Freenode
* Mailing list: [Google Groups](http://groups.google.com/group/vagrant-up)

Vagrant is a tool for building and distributing development environments.

Vagrant provides the framework and configuration format to create and
manage complete portable development environments. These development
environments can live on your computer or in the cloud, and are portable
between Windows, Mac OS X, and Linux.

## Quick Start

First, make sure your development machine has [VirtualBox](http://www.virtualbox.org)
installed. After this, [download and install the appropriate Vagrant package for your OS](http://downloads.vagrantup.com). If you're not on Mac OS X or Windows, you'll need
to add `/opt/vagrant/bin` to your `PATH`. After this, you're ready to go!

To build your first drupal virtual environment from scratch:

    git clone https://github.com/amfranco/vagrant-drupal.git
    cd vagrant-drupal
    git submodule init
    git submodule update
    vagrant up

## Vagrantfile

It is common to modify the [Vagrantfile](https://github.com/ksorokin/vagrant-drupal/blob/master/Vagrantfile) to meet project needs. Read through the comments in the Vagrantfile as well as the [official documentation](http://docs.vagrantup.com/v2/) for other possible configurations.

##Attributes

Apache config

    default["finalize"]["server_name"] =                "drupal-site"
    default["finalize"]["apache2"]["docroot"] =         "/vagrant/www"


Drupal config

    default["finalize"]["drupal"]["pressflow"] =        false
    default["finalize"]["drupal"]["sites_subdir"] =     "default"
    default["finalize"]["drupal"]["major_version"] =    "7"
    default["finalize"]["drupal"]["install_profile"] =  "standard"
    default["finalize"]["drupal"]["account_name"] =     "admin"
    default["finalize"]["drupal"]["account_pass"] =     "admin"
    default["finalize"]["drupal"]["preferred_state"] =  "stable"
    default["finalize"]["drupal"]["theme"] = "omega"
    default["finalize"]["drupal"]["modules_preset"] =   %w{entity
                                                            features
                                                            libraries
                                                            devel
                                                            token
                                                            ctools
                                                            pathauto
                                                            rules
                                                            admin_menu}

### Cookbooks

Take a look for used cookbooks to learn more about available options
* [git](https://github.com/opscode-cookbooks/git) - git installation
* [apache2](https://github.com/opscode-cookbooks/apache2) - opscode apache2 w/ LWRP
* [php](https://github.com/opscode-cookbooks/php) - php/pear
* [mysql](https://github.com/opscode-cookbooks/mysql) - mysql installtion
* [drush](https://github.com/ksorokin/chef-drush.git) - install drush, required by finalize to download, unpack and install drupal with predefined modules
* [finalize](https://github.com/ksorokin/vagrant-drupal/tree/master/cookbooks-local/finalize) - completes environment configuration
