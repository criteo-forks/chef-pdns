#
# Cookbook Name:: pdns
# Resources:: pdns_authoritative_install_debian
#
# Copyright 2014-2017 Aetrion LLC. dba DNSimple
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

resource_name :pdns_authoritative_repo_debian

provides :pdns_authoritative_repo, platform: 'debian' do |node|
  node['platform_version'].to_i >= 8
end

provides :pdns_authoritative_repo, platform: 'ubuntu' do |node|
  node['platform_version'].to_i >= 14
end

property :instance_name, String, name_property: true
property :uri, String, default: lazy { "http://repo.powerdns.com/#{node['platform']}" }
property :distribution, String, default: lazy { "#{node['lsb']['codename']}-auth-40" }
property :key, String, default: 'https://repo.powerdns.com/FD380FBB-pub.asc'
property :debug, [true, false], default: false

action :install do
  apt_repository 'powerdns-authoritative' do
    uri new_resource.uri
    distribution new_resource.distribution
    arch node['kernel']['machine'] == 'x86_64' ? 'amd64': 'i386'
    components ['main']
    key new_resource.key
  end

  apt_preference 'pdns-*' do
    pin          "origin #{URI(new_resource.uri).host}"
    pin_priority '600'
  end
end

action :uninstall do
  apt_repository 'powerdns-authoritative' do
    uri new_resource.uri
    distribution new_resource.distribution
    arch node['kernel']['machine'] == 'x86_64' ? 'amd64': 'i386'
    components ['main']
    key new_resource.key
    action :remove
  end

  apt_preference 'pdns-*' do
    action :remove
  end
end

action_class.class_eval do
  def whyrun_supported?
    true
  end
end
