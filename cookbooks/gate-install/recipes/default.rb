#
# Cookbook:: gate-install
# Recipe:: default
#
# Copyright:: 2018, Ajey Gore
#

#variabls

app_name = node['app_name']
gate_script_location = node['gate_script_location']
command_name = node['command_name']
thread = node['thread']

puts "App Name: #{app_name}"
puts "Gate Script: #{gate_script_location}"

package 'software-properties-common'

apt_repository 'brightbox-ruby' do
  uri 'ppa:brightbox/ruby-ng'
end

apt_update 

package 'ruby2.4'
package 'ruby2.4-dev'
package 'nodejs'
package 'build-essential' 
package 'patch'
package 'ruby-dev' 
package 'zlib1g-dev'
package 'liblzma-dev'
package 'libmysqlclient-dev'
package 'ruby-switch'

execute "make ruby2.4 default" do
  command "/usr/bin/ruby-switch --set ruby2.4"
end

gem_package 'bundler'

#create the group

group app_name do
  action :create
  gid 2000
end

#create the user
user app_name do
  comment 'Gate SSO Application user'
  uid 2000
  gid 2000
  home "/opt/#{app_name}"
  manage_home true
  shell '/bin/bash'
  action :create
end

release_file = JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(""))["assets"][0]["browser_download_url"]
release_name = "#{JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(''))['tag_name']}"

execute "make source directory" do
  command "mkdir -p /opt/#{app_name}/#{release_name}"
  user app_name
  group app_name
  action :run
  not_if { ::File.exist?("/opt/#{app_name}/#{JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(''))['tag_name']}") } 
end


#remote_file "/opt/#{app_name}/#{release_name}.tar.gz" do
#  puts release_file
#  puts release_name
#  source release_file
#  owner app_name
#  group app_name
#  mode '0644'
#  action :create
#  not_if { ::File.exist?("/opt/#{app_name}/#{release_name}.tar.gz") } 
#end

tar_extract release_file  do
  target_dir "/opt/#{app_name}/#{release_name}"
  download_dir "/opt/#{app_name}"
  creates "#{release_name}/Gemfile"
  puts "user for tar: #{app_name}"
  user "#{app_name}"
  group "#{app_name}"
  notifies :restart, "service[puma]", :delayed
end 

link "/opt/#{app_name}/#{app_name}"  do
  to "/opt/#{app_name}/#{release_name}"
  action :create
  user app_name
  group app_name
end

execute "make source directory" do
  command "mkdir -p /etc/puma"
  action :run
  not_if { ::File.exist?("/etc/puma") }
end

directory "/var/run/#{app_name}" do
  owner app_name
  group app_name
  mode 0755
  action :create
end

template "/etc/puma/#{app_name}.rb" do
  source "puma.conf.erb"
  owner app_name
  group app_name
  variables( 
            app_name: app_name,
            app_home: app_name
           )
  mode "400"
end

template gate_script_location do
  source "gate_script.sh.erb"
  mode   "0755"
  owner app_name
  group app_name
  variables( app_name: app_name, app_home: app_name, command_name: command_name )
  notifies :restart, "service[puma]", :delayed
end

template "/etc/systemd/system/puma.service" do
  source "systemd.erb"
  owner app_name
  group app_name
  mode "00644"
  variables( app_name: app_name, app_home: app_name, gate_script_location: gate_script_location )
  notifies :run, "execute[systemctl-daemon-reload]", :immediately
  notifies :restart, "service[puma]", :delayed
end

execute 'systemctl-daemon-reload' do
  command '/bin/systemctl --system daemon-reload'
end

service "puma" do
  action :enable
  supports :status => true, :start => true, :restart => true, :stop => true
  provider Chef::Provider::Service::Systemd
end

