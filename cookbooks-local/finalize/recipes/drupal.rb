#
# Cookbook Name:: finalize
# Recipe:: drupal
#
# Copyright 2013, Konstantin Sorokin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may 1obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "drush"
include_recipe "cron"

#Base drupal path
drupal_path = node["finalize"]["apache2"]["docroot"]

# Modules to disable
disable_modules_list = node["finalize"]["drupal"]["disable_modules"].join(",")

# Modules to dl/en
modules_list = node["finalize"]["drupal"]["modules_preset"].concat([node["finalize"]["drupal"]["theme"]]).join(",")

case node["finalize"]["drupal"]["install_option"]
when 1
	# We are installing using a makefile
	if node["finalize"]["drupal"]["makefile"] != ""
		drush_execute "make" do
			cwd drupal_path
			options %W{#{node["finalize"]["drupal"]["makefile"]}
						--y}
		end
		#MySQL dsn
		mysql_dsn = "mysql://root"
		mysql_dsn << ":#{node.set_unless['mysql']['server_root_password']}"
		mysql_dsn << "@localhost/#{node["finalize"]["server_name"]}"
		# install drupal
		drush_execute "site-install" do
			cwd drupal_path
			options %W{#{node["finalize"]["drupal"]["install_profile"]}
						 --sites-subdir=#{node["finalize"]["drupal"]["sites_subdir"]}
						 --site-name=#{node["finalize"]["drupal"]["site_name"]}
						 --account-name=#{node["finalize"]["drupal"]["account_name"]}
						 --account-pass=#{node["finalize"]["drupal"]["account_pass"]}
						 --db-url=#{mysql_dsn}}
		end

		# drush pm-enable
		drush_execute "en" do
			cwd drupal_path
			options %W{#{modules_list}
					   --resolve-dependencies}
		end

		# drush pm-dis
		drush_execute "dis" do
			cwd drupal_path
			options %W{#{disable_modules_list}}
		end

		# Set up cron job
		cron_d "cron-job" do
		  minute 10
		  command "wget -O - -q -t 1 http://localhost/cron.php"
		end
	end
when 2
	# We are installing from the scratch
	if !File.exists? drupal_path + "/index.php"
		if node["finalize"]["drupal"]["pressflow"]
			# Git sync
			include_recipe "git"
			git drupal_path + "/drupal" do
				repository "https://github.com/pressflow/#{node["finalize"]["drupal"]["major_version"]}.git"
				action :sync
			end
			directory drupal_path + "/drupal/.git" do
				recursive true
				ignore_failure true
				action :delete
			end
		else
			drush_execute "dl" do
				options %W{drupal
						  --default-major=#{node["finalize"]["drupal"]["major_version"]}
						  --drupal-project-rename=drupal
						  --destination=#{drupal_path}}
			end
		end

		execute "drupal_extract" do
			command "mv #{drupal_path}/drupal/* #{drupal_path}/drupal/.[a-zA-Z0-9\_]* #{drupal_path} && rm -rf #{drupal_path}/drupal"
		end
	end

	if !File.exists? drupal_path + "/sites/" + node["finalize"]["drupal"]["sites_subdir"] + "/settings.php"
		#MySQL dsn
		mysql_dsn = "mysql://root"
		mysql_dsn << ":#{node.set_unless['mysql']['server_root_password']}"
		mysql_dsn << "@localhost/#{node["finalize"]["server_name"]}"

		#Install drupal
		drush_execute "site-install" do
			cwd drupal_path
			options %W{#{node["finalize"]["drupal"]["install_profile"]}
						 --sites-subdir=#{node["finalize"]["drupal"]["sites_subdir"]}
						 --site-name=#{node["finalize"]["drupal"]["site_name"]}
						 --account-name=#{node["finalize"]["drupal"]["account_name"]}
						 --account-pass=#{node["finalize"]["drupal"]["account_pass"]}
						 --db-url=#{mysql_dsn}}
		end

		# Install bootstrap modules
		if node["finalize"]["drupal"]["preferred_state"] == "dev"
			preferred_state = "--dev"
		else
			 preferred_state = ""
		end
		modules_list = node["finalize"]["drupal"]["modules_preset"].concat([node["finalize"]["drupal"]["theme"]]).join(",")

		# drush pm-download
		drush_execute "dl" do
			#cwd drupal_path
			options %W{#{modules_list}
					   #{preferred_state}
					   --default-major=#{node["finalize"]["drupal"]["major_version"]}}
		end

		# drush pm-enable
		drush_execute "en" do
			cwd drupal_path
			options %W{#{modules_list}
					   --resolve-dependencies}
		end

		# drush pm-dis
		drush_execute "dis" do
			cwd drupal_path
			options %W{#{disable_modules_list}}
		end

		# Set default theme
		drush_execute "vset" do
			cwd drupal_path
			options ["theme_default #{node["finalize"]["drupal"]["theme"]}"]
		end

		# Set up cron job
		cron_d "cron-job" do
		  minute 10
		  command "wget -O - -q -t 1 http://localhost/cron.php"
		end
	end
when 3
	# Install using a profile
	#MySQL dsn
	mysql_dsn = "mysql://root"
	mysql_dsn << ":#{node.set_unless['mysql']['server_root_password']}"
	mysql_dsn << "@localhost/#{node["finalize"]["server_name"]}"
	# Install using a profile
	drush_execute "site-install" do
		cwd drupal_path
		options %W{#{node["finalize"]["drupal"]["install_profile"]}
					 --sites-subdir=#{node["finalize"]["drupal"]["sites_subdir"]}
					 --site-name=#{node["finalize"]["drupal"]["site_name"]}
					 --account-name=#{node["finalize"]["drupal"]["account_name"]}
					 --account-pass=#{node["finalize"]["drupal"]["account_pass"]}
					 --db-url=#{mysql_dsn}}
	end
	# Set up cron job
	cron_d "cron-job" do
	  minute 10
	  command "wget -O - -q -t 1 http://localhost/cron.php"
	end
end


# drush cache-clear
drush_execute "cc" do
    cwd drupal_path
end

__END__
# Are we installing using a makefile?
if node["finalize"]["drupal"]["makefile"] != ""
	drush_execute "make" do
		cwd drupal_path
		options %W{#{node["finalize"]["drupal"]["makefile"]}
					--y}
	end
	#MySQL dsn
	mysql_dsn = "mysql://root"
	mysql_dsn << ":#{node.set_unless['mysql']['server_root_password']}"
	mysql_dsn << "@localhost/#{node["finalize"]["server_name"]}"
	# install drupal
	drush_execute "site-install" do
		cwd drupal_path
		options %W{#{node["finalize"]["drupal"]["install_profile"]}
					 --sites-subdir=#{node["finalize"]["drupal"]["sites_subdir"]}
					 --site-name=#{node["finalize"]["drupal"]["site_name"]}
					 --account-name=#{node["finalize"]["drupal"]["account_name"]}
					 --account-pass=#{node["finalize"]["drupal"]["account_pass"]}
					 --db-url=#{mysql_dsn}}
	end
else

	# Are we installing from the scratch?
	if node["finalize"]["drupal"]["new_install"]

		if !File.exists? drupal_path + "/index.php"
			if node["finalize"]["drupal"]["pressflow"]
				# Git sync
				include_recipe "git"
				git drupal_path + "/drupal" do
					repository "https://github.com/pressflow/#{node["finalize"]["drupal"]["major_version"]}.git"
					action :sync
				end
				directory drupal_path + "/drupal/.git" do
					recursive true
					ignore_failure true
					action :delete
				end
			else
				drush_execute "dl" do
					options %W{drupal
							  --default-major=#{node["finalize"]["drupal"]["major_version"]}
							  --drupal-project-rename=drupal
							  --destination=#{drupal_path}}
				end
			end

			execute "drupal_extract" do
				command "mv #{drupal_path}/drupal/* #{drupal_path}/drupal/.[a-zA-Z0-9\_]* #{drupal_path} && rm -rf #{drupal_path}/drupal"
			end
		end

		if !File.exists? drupal_path + "/sites/" + node["finalize"]["drupal"]["sites_subdir"] + "/settings.php"
			#MySQL dsn
			mysql_dsn = "mysql://root"
			mysql_dsn << ":#{node.set_unless['mysql']['server_root_password']}"
			mysql_dsn << "@localhost/#{node["finalize"]["server_name"]}"

			#Install drupal
			drush_execute "site-install" do
				cwd drupal_path
				options %W{#{node["finalize"]["drupal"]["install_profile"]}
							 --sites-subdir=#{node["finalize"]["drupal"]["sites_subdir"]}
							 --site-name=#{node["finalize"]["drupal"]["site_name"]}
							 --account-name=#{node["finalize"]["drupal"]["account_name"]}
							 --account-pass=#{node["finalize"]["drupal"]["account_pass"]}
							 --db-url=#{mysql_dsn}}
			end

			# Install bootstrap modules
			if node["finalize"]["drupal"]["preferred_state"] == "dev"
				preferred_state = "--dev"
			else
				 preferred_state = ""
			end
			modules_list = node["finalize"]["drupal"]["modules_preset"].concat([node["finalize"]["drupal"]["theme"]]).join(",")
			disable_modules_list = node["finalize"]["drupal"]["disable_modules"].join(",")

			# drush pm-download
			drush_execute "dl" do
				#cwd drupal_path
				options %W{#{modules_list}
						   #{preferred_state}
						   --default-major=#{node["finalize"]["drupal"]["major_version"]}}
			end

			# drush pm-enable
			drush_execute "en" do
				cwd drupal_path
				options %W{#{modules_list}
						   --resolve-dependencies}
			end

			# drush pm-dis
			drush_execute "dis" do
				options %W{#{disable_modules_list}}
			end

			# Set default theme
			drush_execute "vset" do
				cwd drupal_path
				options ["theme_default #{node["finalize"]["drupal"]["theme"]}"]
			end

			# Set up cron job
			cron_d "cron-job" do
			  minute 10
			  command "wget -O - -q -t 1 http://localhost/cron.php"
			end
		end
	else

		#MySQL dsn
		mysql_dsn = "mysql://root"
		mysql_dsn << ":#{node.set_unless['mysql']['server_root_password']}"
		mysql_dsn << "@localhost/#{node["finalize"]["server_name"]}"
		# Install using a profile
		drush_execute "site-install" do
			cwd drupal_path
			options %W{#{node["finalize"]["drupal"]["install_profile"]}
						 --sites-subdir=#{node["finalize"]["drupal"]["sites_subdir"]}
						 --site-name=#{node["finalize"]["drupal"]["site_name"]}
						 --account-name=#{node["finalize"]["drupal"]["account_name"]}
						 --account-pass=#{node["finalize"]["drupal"]["account_pass"]}
						 --db-url=#{mysql_dsn}}
		end
	end

end

