$script = <<-'SCRIPT'
set +ex  
echo "Regenerate and distribute Keys"
dnf install sshpass -y
dnf install git -y

whoami

sudo su
cd ~
whoami
 
ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1
sshpass -p "choclo123" ssh-copy-id -o StrictHostKeyChecking=no root@172.16.128.4
sshpass -p "choclo123" ssh-copy-id -o StrictHostKeyChecking=no root@172.16.128.5
sshpass -p "choclo123" ssh-copy-id -o StrictHostKeyChecking=no root@172.16.128.6

pwd

git clone https://github.com/cbarria/almatest.git
cd almatest

pwd

curl -LJO https://github.com/rancher/rke/releases/download/v1.4.1/rke_linux-amd64
chmod +x rke_linux-amd64
mv rke_linux-amd64 /bin/rke

sudo rke up
mkdir ~/.kube
cp kube_config_cluster.yml ~/.kube/config


SCRIPT

Vagrant.configure("2") do |config|
  # This will be applied to every vagrant file that comes after it
  config.vm.box = "almalinux/9"

  # K8s Data Plane
  ## Worker Node 1
  config.vm.define "worker1" do |k8s_worker|
    k8s_worker.vm.provision "shell", path: "node_script.sh"
    k8s_worker.vm.network "private_network", ip: "172.16.128.5"
    k8s_worker.vm.hostname = "worker1"
    k8s_worker.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--audio", "none"]
      v.memory = 2024
      v.cpus = 2
	  unless File.exist?('./SecondDiskNode1.vdi')
        v.customize ['createhd', '--filename', './SecondDiskNode1.vdi', '--variant', 'Fixed', '--size', 5 * 1024]
      end
      v.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', './SecondDiskNode1.vdi']  
    end
  end
  
  ## Worker Node 2
  config.vm.define "worker2" do |k8s_worker|	
    k8s_worker.vm.provision "shell", path: "node_script.sh"
    k8s_worker.vm.network "private_network", ip: "172.16.128.6"
    k8s_worker.vm.hostname = "worker2"
    k8s_worker.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--audio", "none"]
      v.memory = 2024
      v.cpus = 2
	  unless File.exist?('./SecondDiskNode2.vdi')
        v.customize ['createhd', '--filename', './SecondDiskNode2.vdi', '--variant', 'Fixed', '--size', 5 * 1024]
      end
      v.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', './SecondDiskNode2.vdi']
    end
  end
  
  # K8s 
  ## Master Node
  config.vm.define "master" do |k8s_master|
    k8s_master.vm.provision "shell", path: "node_script.sh"
    k8s_master.vm.network "private_network", ip: "172.16.128.4" 
    k8s_master.vm.hostname = "master"
    k8s_master.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--audio", "none"]
      v.memory = 2024
      v.cpus = 2
	  unless File.exist?('./SecondDiskMaster.vdi')
        v.customize ['createhd', '--filename', './SecondDiskMaster.vdi', '--variant', 'Fixed', '--size', 5 * 1024]
      end
      v.customize ['storageattach', :id,  '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', './SecondDiskMaster.vdi']
    end
	
	k8s_master.vm.provision "shell", inline: $script
  end
  
end
