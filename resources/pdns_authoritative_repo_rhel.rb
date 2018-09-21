#
# Cookbook Name:: pdns
# Resources:: pdns_authoritative_install_rhel
#
# Copyright 2016-2017 Aetrion LLC. dba DNSimple
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
include ::Pdns::Helpers

resource_name :pdns_authoritative_repo_rhel

provides :pdns_authoritative_repo, platform: 'centos' do |node|
  node['platform_version'].to_i >= 6
end

property :instance_name, String, name_property: true
property :baseurl, String, default: ::Pdns::Helpers::REDHAT_URL['auth']['baseurl']
property :gpgkey, String, default: ::Pdns::Helpers::REDHAT_URL['auth']['gpgkey']
property :baseurl_debug, String, default: ::Pdns::Helpers::REDHAT_URL['auth']['baseurl_debug']
property :debug, [TrueClass, FalseClass], default: false

action :install do
  package 'epel-release' do
    action :install
    only_if { node['platform_version'].to_i == 6 }
  end

  repo_name = repository_name(new_resource.baseurl, new_resource.instance_name)
  yum_repository repo_name do
    description 'PowerDNS repository for PowerDNS Authoritative'
    baseurl new_resource.baseurl
    gpgkey new_resource.gpgkey
    priority '90'
    includepkgs 'pdns*'
    action :create
  end

  yum_repository "#{repo_name}-debuginfo" do
    description 'PowerDNS repository for PowerDNS Authoritative - debug symbols'
    baseurl new_resource.baseurl_debug
    gpgkey new_resource.gpgkey
    priority '90'
    includepkgs 'pdns*'
    action :create
    not_if { new_resource.debug }
  end
end

action :uninstall do
  repo_name = repository_name(new_resource.baseurl, new_resource.instance_name)
  yum_repository repo_name do
    action :delete
  end

  yum_repository "#{repo_name}-debuginfo" do
    action :delete
  end
end

action_class.class_eval do
  def whyrun_supported?
    true
  end
end
