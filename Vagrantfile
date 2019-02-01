VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "ubuntu/bionic64"

    config.vm.synced_folder "grav/", "/grav",
        id: "core",
        :nfs => true,
        :mount_options => ['nolock,vers=3,udp,noatime']

    config.vm.network "private_network", ip: "192.168.11.11"

    config.vm.provider :virtualbox do |vb|
        host = RbConfig::CONFIG['host_os']

        if host =~ /darwin/
            cpus = `sysctl -n hw.ncpu`.to_i / 2
            mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4

        elsif host =~ /linux/
            cpus = `nproc`.to_i
            mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4

        elsif host =~ /mswin32/
            cpus = `echo %NUMBER_OF_PROCESSORS%`.to_i / 2
            mem = `wmic computersystem get TotalPhysicalMemory`.to_i / 1024 / 1024 / 4
        else
            cpus = 4
            mem = 4096
        end

        vb.customize ["modifyvm", :id, "--memory", mem]
        vb.customize ["modifyvm", :id, "--cpus", cpus]
    end

    config.vm.provision :shell, :path => "bootstrap.sh"

end
