#
# Cookbook:: gate-install
# Recipe:: default
#
# Copyright:: 2018, Ajey Gore
#
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

gem_package 'bundler'

#create the group

group 'gate_sso' do
  action :create
  gid 2000
end

#create the user
user 'gate_sso' do
  comment 'Gate SSO Application user'
  uid 2000
  gid 'gate_sso'
  home '/opt/gate_sso'
  manage_home true
  shell '/bin/bash'
  action :create
end


execute "make source directory" do
  command "mkdir -p /opt/gate_sso/#{JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(''))['tag_name']}"
  user 'gate_sso'
  action :run
  not_if { ::File.exist?("/opt/gate_sso/#{JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(''))['tag_name']}") } 
end

remote_file "/opt/gate_sso/#{JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(''))['tag_name']}.tar.gz" do
  source JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(""))["assets"][0]["browser_download_url"]
  owner 'gate_sso'
  group 'gate_sso'
  mode '0644'
  action :create
  not_if { ::File.exist?("/opt/gate_sso/#{JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(''))['tag_name']}.tar.gz") } 
end

tar_extract JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(""))["assets"][0]["browser_download_url"] do
  target_dir "/opt/gate_sso/#{JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(''))['tag_name']}"
  creates "/opt/gate_sso/#{JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(''))['tag_name']}/Gemfile"
end 


