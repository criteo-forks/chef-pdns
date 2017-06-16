#
# Cookbook Name:: pdns
# Libraries:: recursor_helpers
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
module PdnsResource
  module Helpers
    def default_user_attributes
      case node['platform_family']
      when 'debian'
        { home: '/var/spool/powerdns', shell: '/bin/false' }
      when 'rhel'
        { home: '/', shell: '/sbin/nologin' }
      end
    end
  end
end

module Pdns
  # Common helper for PowerDNS cookbook
  module Helpers
    REDHAT_URL = Mash.new(
      auth: {
        baseurl: 'http://repo.powerdns.com/centos/$basearch/$releasever/auth-40',
        gpgkey: 'https://repo.powerdns.com/CBC8B383-pub.asc',
        baseurl_debug: 'http://repo.powerdns.com/centos/$basearch/$releasever/auth-40/debug',
      },
      rec: {
        baseurl: 'http://repo.powerdns.com/centos/$basearch/$releasever/rec-40',
        gpgkey: 'https://repo.powerdns.com/FD380FBB-pub.asc',
        baseurl_debug: 'http://repo.powerdns.com/centos/$basearch/$releasever/rec-40/debug',
      },
    ).freeze unless constants.include? :REDHAT_URL

    def repository_name(url = REDHAT_URL['auth']['baseurl'], name = '')
      "powerdns-#{url.split('/').last}-#{name}"
    end

    def copy_properties_to(to, *properties)
      properties = self.class.properties.keys if properties.empty?
      properties.each do |p|
        # If the property is set on from, and exists on to, set the
        # property on to
        if to.class.properties.include?(p) && property_is_set?(p)
          to.send(p, send(p))
        end
      end
    end
  end
end
