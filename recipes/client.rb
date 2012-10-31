#
# Cookbook Name:: collectd
# Recipe:: client
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

case node['collectd']['install_type']
when 'source'
  include_recipe "collectd::_install_from_source"
when 'package'
  include_recipe "collectd::_install_from_package"
end

include_recipe "collectd::_server_conf"

case node.platform_family
when 'rhel', 'fedora'
  include_recipe "collectd::_server_service"
when 'debian', 'ubuntu'
  include_recipe "collectd::_server_runit"
end

servers = []

if Chef::Config[:solo]
  if node['collectd']['server_address']
    servers << node['collectd']['server_address']
  else
    servers << '127.0.0.1'
  end
else
  search(:node, "role:#{node['collectd']['server_role']} AND #{node.chef_environment}") do |n|
    servers << n['fqdn']
  end
end

collectd_plugin "network" do
  options :server => servers
  type 'plugin'
end
