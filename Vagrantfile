# -*- mode: ruby -*-
# vi: set ft=ruby :

# ------------------------------------------------------------------------
# CONFIGURABLE PROPERTIES
# ------------------------------------------------------------------------

$project    = 'projectname'
$hostname   = $project + '.local'
$docroot    = '/var/www/' + $project +'/html/'

# ------------------------------------------------------------------------

Vagrant.require_version '>= 1.5.1'

unless Vagrant.has_plugin?("vagrant-hostmanager")
    raise 'vagrant-hostmanager is missing, please install the plugin with `vagrant plugin install vagrant-hostmanager`'
end

unless Vagrant.has_plugin?("vagrant-vbguest")
    raise 'vagrant-vbguest is missing, please install the plugin with `vagrant plugin install vagrant-vbguest`'
end

Vagrant.configure('2') do |config|

    # Set virtualbox memory
    config.vm.provider :virtualbox do |virtualbox|
        virtualbox.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        virtualbox.customize ['modifyvm', :id, '--memory', "1024"]
        virtualbox.customize ['modifyvm', :id, '--cpus', "1"]
        virtualbox.customize ['modifyvm', :id, '--name', $hostname]
    end

    # Configure Hosts Manager
    if Vagrant.has_plugin?('vagrant-hostmanager')
        config.vm.provision :hostmanager
        config.hostmanager.enabled = false
        config.hostmanager.manage_host = true
        config.hostmanager.ignore_private_ip = false
        config.hostmanager.include_offline = true

        # Get DHCP address
        config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
            if hostname = (vm.ssh_info && vm.ssh_info[:host])
                `vagrant ssh -c "hostname -I"`.split()[1]
            end
        end
    end


    config.vm.define $project do |node|
        node.vm.box = 'scotch/box'
        node.vm.hostname = $hostname
        node.vm.network "private_network", type: "dhcp"
        node.vm.synced_folder ".", "/var/www/" + $project + "/", type: "nfs"
        if Vagrant.has_plugin?('vagrant-hostmanager')
            node.hostmanager.aliases = [ "www." + $hostname, 'kibana.' + $hostname ]
        end
    end

    # Add composer to path
    config.vm.provision "shell", inline: 'export PATH="~/.composer/vendor/bin:$PATH"'

    # Create project database
    # config.vm.provision "shell", inline: "mysql -u root -e 'CREATE DATABASE #{$project}_local;DROP DATABASE scotchbox';"

    ## Add VHosts setup
    # config.vm.provision "shell" do |s|
    #    s.path = "vagrant-scotchbox-vhost.sh"
    #    s.args = "-d #{$hostname} -w #{$docroot}"
    # end

    ## Add Elasticsearch
    # config.vm.provision "shell" do |s|
    #    s.path = "vagrant-elasticsearch.sh"
    # end

    ## Add Kibana
    # config.vm.provision "shell" do |s|
    #    s.path = "vagrant-kibana.sh"
    #    s.args = "-v 4.4 --host kibana.#{$hostname}"
    # end
end