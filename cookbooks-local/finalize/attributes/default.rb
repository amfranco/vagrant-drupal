#
# Cookbook Name:: finalize
# Recipe:: default
#
# Copyright 2013, Konstantin Sorokin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default["finalize"]["server_name"] =                "drupal-site"
default["finalize"]["apache2"]["docroot"] =         "/vagrant/www"

default["finalize"]["drupal"]["pressflow"] = false
default["finalize"]["drupal"]["sites_subdir"] =     "default"
default["finalize"]["drupal"]["major_version"] = "7"
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

case node[:platform]
when "redhat", "centos"
    default["finalize"]["php"]["packages"] = ["memcached", "ImageMagick", "ImageMagick-devel", "php-pecl-apc",
                                                "php-pecl-memcache", "php-pdo", "php-common", "php-mbstring", "php-xml",
                                                "php-xmlrpc", "php-soap", "php-gd", "php-intl", "php-mysql"]
when "debian", "ubuntu"
    default["finalize"]["php"]["packages"] = ["memcached", "imagemagick", "libmagickcore-dev", "libmagickwand-dev",
                                                "php-apc", "php5-memcache", "php5-memcached", "php5-common",
                                                "php5-cli", "php5-xmlrpc", "php-soap", "php5-gd", "php5-intl",
                                                "php5-mysql", "libapache2-mod-php5"]
end