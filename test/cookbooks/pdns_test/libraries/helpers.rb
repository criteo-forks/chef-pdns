VERSION_REC = '4.0.8-1pdns'.freeze unless defined?(VERSION_REC)
VERSION_AUTH = '4.0.5-1pdns'.freeze unless defined?(VERSION_AUTH)

def recursor_version_per_platform
  case node['platform']
  when 'debian'
    "#{VERSION_REC}.jessie"
  when 'ubuntu'
    "#{VERSION_REC}.#{node['lsb']['codename']}"
  when 'centos'
    "#{VERSION_REC}.el#{node['packages']['centos-release']['version']}"
  end
end

def authoritative_version_per_platform
  case node['platform']
  when 'debian'
    "#{VERSION_AUTH}.jessie"
  when 'ubuntu'
    "#{VERSION_AUTH}.#{node['lsb']['codename']}"
  when 'centos'
    "#{VERSION_AUTH}.el#{node['packages']['centos-release']['version']}"
  end
end
