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

provides :pdns_authoritative_install, os: 'linux'

property :instance_name, String, name_property: true
property :version, [String, nil], default: nil
property :uri, String, default: lazy { "http://repo.powerdns.com/#{node['platform']}" }
property :distribution, String, default: lazy { "#{node['lsb']['codename']}-auth-40" }
property :key, String, default: 'https://repo.powerdns.com/FD380FBB-pub.asc'
property :baseurl, String, default: ::Pdns::Helpers::REDHAT_URL['auth']['baseurl']
property :gpgkey, String, default: ::Pdns::Helpers::REDHAT_URL['auth']['gpgkey']
property :baseurl_debug, String, default: ::Pdns::Helpers::REDHAT_URL['auth']['baseurl_debug']
property :debug, [TrueClass, FalseClass], default: false

action :install do
  yum_package 'epel-release' do
    action :install
    only_if { node['platform_family'] == 'rhel' && node['platform_version'].to_i == 6 }
  end

  # Automatic repository selection
  copy_properties_to(pdns_authoritative_repo(new_resource.instance_name))

  package pkg_name do
    version new_resource.version if new_resource.version
  end

  package pkg_name_debug do
    version new_resource.version if new_resource.version
    only_if { new_resource.debug }
  end

end

action :uninstall do
  package pkg_name do
    action :remove
  end

  package pkg_name_debug do
    only_if { new_resource.debug }
    action :remove
  end

  copy_properties_to(pdns_authoritative_repo(new_resource.instance_name) { action :delete })
end

action_class.class_eval do
  def whyrun_supported?
    true
  end

  def pkg_name
    case node['platform_family']
    when 'rhel'
      'pdns'
    when 'debian'
      'pdns-server'
    end
  end

  def pkg_name_debug
    case node['platform_family']
    when 'rhel'
      'pdns-debuginfo'
    when 'debian'
      'pdns-server-dbg'
    end
  end
end
