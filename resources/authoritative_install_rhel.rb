#
# Cookbook Name:: pdns
# Resources:: pdns_authoritative_install_rhel
#
# Copyright 2016-2018 DNSimple Corp
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

provides :pdns_authoritative_install, platform_family: 'rhel' do |node|
  node['platform_version'].to_i >= 6
end

property :instance_name, String, name_property: true
property :version, [String, nil], default: nil
property :debug, [true, false], default: false

action :install do
  yum_package 'epel-release' do
    action :install
    only_if { node['platform_version'].to_i == 6 }
  end

  yum_repository 'powerdns-auth-40' do
    description 'PowerDNS repository for PowerDNS Authoritative - version 4.0.X'
    baseurl 'http://repo.powerdns.com/centos/$basearch/$releasever/auth-40'
    gpgkey 'https://repo.powerdns.com/FD380FBB-pub.asc'
    priority '90'
    includepkgs 'pdns*'
    action :create
  end

  yum_repository 'powerdns-auth-40-debuginfo' do
    description 'PowerDNS repository for PowerDNS Authoritative - version 4.0.X debug symbols'
    baseurl 'http://repo.powerdns.com/centos/$basearch/$releasever/auth-40/debug'
    gpgkey 'https://repo.powerdns.com/FD380FBB-pub.asc'
    priority '90'
    includepkgs 'pdns*'
    action :create
    not_if { new_resource.debug }
  end

  yum_package 'pdns' do
    version new_resource.version
  end
end

action :uninstall do
  yum_package 'pdns' do
    action :remove
    version new_resource.version
  end
end
