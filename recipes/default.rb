#
# Cookbook Name:: nginx
# Recipe:: default
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008-2012, Opscode, Inc.
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

if node['platform'] == "ubuntu" && node[:nginx][:ppa_package]
  include_recipe "apt"

  apt_repository "nginx-stable" do
    uri "http://ppa.launchpad.net/nginx/stable/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "C300EE8C"
    notifies :run, resources(:execute => "apt-get update"), :immediately
  end

else
  package "nginx"
end

include_recipe 'nginx::ohai_plugin'

case node['nginx']['install_method']
when 'source'
  include_recipe 'nginx::source'
when 'package'
  case node['platform']
  when 'redhat','centos','scientific','amazon','oracle'
    include_recipe 'yum::epel'
  end
  package 'nginx'
  service 'nginx' do
    supports :status => true, :restart => true, :reload => true
    action :enable
  end
  include_recipe 'nginx::commons'
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action :start
end
