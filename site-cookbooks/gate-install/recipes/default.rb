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

file '/tmp/hello.txt' do
  content '<html>This is a placeholder for the home page.</html>'
  mode '0755'
end
