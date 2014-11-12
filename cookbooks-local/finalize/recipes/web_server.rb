#
# Cookbook Name:: finalize
# Recipe:: apache2
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
# distributed under the License is istributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
::Chef::Recipe.send(:include, Chef::Mixin::ShellOut)

# Varnish platform specific config, fix for unsupported platforms
case node[:platform]
when "centos", "redhat"
  shell_out("rpm --nosignature -vi http://repo.varnish-cache.org/redhat/varnish-3.0/el5/noarch/varnish-release-3.0-1.el5.centos.noarch.rpm")
  node.set['varnish']['dir']     = "/etc/varnish"
  node.set['varnish']['default'] = "/etc/default/varnish"
when "ubuntu", "debian"
 command = "wget -qO - http://repo.varnish-cache.org/debian/GPG-key.txt | sudo apt-key add -"
 command << " && echo \"deb http://repo.varnish-cache.org/ubuntu/ precise varnish-3.0\" | sudo tee -a /etc/apt/sources.list"
 command << " && apt-get update"
 shell_out(command)
end

# Varnish configuration
node.set['varnish']['storage_file'] = '/var/lib/varnish/varnish_storage.bin'
node.set['varnish']['vcl_source'] = "varnish.erb"
node.set['varnish']['vcl_cookbook'] = "finalize"
node.set['varnish']['conf_cookbook'] = "finalize"
node.set['varnish']['storage_size'] = "256MB"
node.set['varnish']['version'] = "3.0.1"

include_recipe "varnish"

template "#{node['nginx']['dir']}/sites-available/default" do
  source "nginx-site.erb"
  owner "root"
  group "root"
  mode 00644
  variables(
    :server_name => node["finalize"]["server_name"],
    :varnish => node['varnish'],
    :docroot => node["finalize"]["apache2"]["docroot"]
  )
  notifies :reload, 'service[nginx]'
end

nginx_site "default" do
    enable true
end

web_app node["finalize"]["server_name"] do
  server_port node['varnish']['backend_port']
  server_name node["finalize"]["server_name"]
  server_aliases ["*." + node["finalize"]["server_name"]]
  docroot node["finalize"]["apache2"]["docroot"]
  allow_override "All"
end

# Edit hosts file
hostsfile_entry '127.0.0.1' do
  hostname  node["finalize"]["server_name"]
  action    :create_if_missing
end
