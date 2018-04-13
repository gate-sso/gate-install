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


file '/tmp/gate_source.zip' do
  content 'this is temp file'
  mode '0755'
end

remote_file '/tmp/gate_source.zip' do
  source 'https://codeload.github.com/gate-sso/gate/zip/master'
  owner 'gate_sso'
  group 'gate_sso'
  mode '0644'
  action :create
end

zipfile '/tmp/gate_source.zip' do
  into '/opt/gate_sso/'
  overwrite true
end

execute "chown-directory-gate-source" do
  command "chown -R gate_sso:gate_sso /opt/gate_sso/gate-master"
  user "root"
  action :run
  not_if "stat -c %U /opt/gate_sso/gate_master |grep gate_sso"
end

remote_file '/opt/gate_sso/gate_release.tar.gz' do
  source JSON.parse(Chef::HTTP.new('https://api.github.com/repos/gate-sso/gate/releases/latest').get(""))["assets"][0]["browser_download_url"]
  owner 'gate_sso'
  group 'gate_sso'
  mode '0644'
  action :create
end


