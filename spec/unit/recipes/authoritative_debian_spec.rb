require 'spec_helper'

describe 'pdns_test::authoritative_install_multi' do
  context 'on ubuntu platform' do
    let(:ubuntu_runner) do
      ChefSpec::SoloRunner.new(
        os: 'linux',
        platform: 'ubuntu',
        version: '14.04',
        step_into: ['pdns_authoritative_install', 'pdns_authoritative_config', 'pdns_authoritative_service'])
    end

    let(:chef_run) { ubuntu_runner.converge(described_recipe) }
    let(:version) { '4.0.4-1pdns.trusty' }

    let(:ubuntu_runner_1604) do
      ChefSpec::SoloRunner.new(
        os: 'linux',
        platform: 'ubuntu',
        version: '16.04',
        step_into: ['pdns_authoritative_install', 'pdns_authoritative_config', 'pdns_authoritative_service'])
    end

    let(:chef_run_1604) { ubuntu_runner_1604.converge(described_recipe) }
    #
    # Tests for the install resource
    #

    # Chef gets node['lsb']['codename'] even if it is not set as an attribute
    it 'adds apt repository' do
      expect(chef_run).to add_apt_repository('powerdns-authoritative')
      .with(uri: 'http://repo.powerdns.com/ubuntu', distribution: 'trusty-auth-40')
    end

    it 'creates apt pin for pdns' do
      expect(chef_run).to add_apt_preference('pdns-*')
      .with(pin: 'origin repo.powerdns.com', pin_priority: '600')
    end

    it 'installs pdns authoritative package' do
      expect(chef_run).to install_apt_package('pdns-server').with(version: version)
    end

    #
    # Tests for the service resource
    #

    it '[sysvinit] creates a specific init script' do
      expect(chef_run).to create_link('/etc/init.d/pdns_authoritative-server_01').with(to: 'pdns')
    end

    it '[sysvinit] enables and starts pdns_authoritative service' do
      expect(chef_run).to enable_service('pdns_authoritative-server_01')
      expect(chef_run).to start_service('pdns_authoritative-server_01')
    end

    it '[systemd] should not creates a specific init script' do
      expect(chef_run_1604).not_to create_link('/etc/init.d/pdns_authoritative-server_01').with(to: 'pdns')
    end

    it '[systemd] enables and starts pdns_authoritative instance' do
      expect(chef_run_1604).to enable_service('pdns@server_01')
      expect(chef_run_1604).to start_service('pdns@server_01')
    end

    #
    # Tests for the config resource
    #

    it 'creates pdns config directory' do
      expect(chef_run).to create_directory('/etc/powerdns')
      .with(owner: 'root', group: 'root', mode: '0755')
    end

    it 'creates pdns authoritative unix user' do
      expect(chef_run).to create_user('pdns')
      .with(home: '/var/spool/powerdns', shell: '/bin/false', system: true)
    end

    it 'creates a pdns authoritative unix group' do
      expect(chef_run).to create_group('pdns')
      .with(members: ['pdns'], system: true)
    end

    it 'creates a authoritative instance config' do
      expect(chef_run).to create_template('/etc/powerdns/pdns-server_01.conf')
      .with(owner: 'root', group: 'root', mode: '0640')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
