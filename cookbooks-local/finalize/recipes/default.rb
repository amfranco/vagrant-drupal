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

package "vim"

include_recipe "finalize::iptables"
include_recipe "finalize::php"
include_recipe "finalize::apache2"

template "/vagrant/www/hosts.txt" do
	source "hosts.erb"
	owner "vagrant"
    group "vagrant"
    mode "0777"
end