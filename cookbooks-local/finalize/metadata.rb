maintainer       "Konstantin Sorokin"
maintainer_email "k.n.sorokin@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures finalize"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

recipe           "finalize",            "Completes basic configuration"
recipe           "finalize::drupal",    "Sets up varnish, solr, drush and install drupal"

version          "0.1.0"
recommends       "git"

depends          "php"
depends          "php-fpm"
depends          "apache2"
depends          "cron"
depends          "drush"
depends          "nginx"
depends          "hostsfile"
#depends          "varnish"

%w{ ubuntu debian centos redhat}.each do |os|
  supports os
end
