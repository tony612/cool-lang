# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "compilers"

  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # Get course contents and place them in /usr/class/cs143:
  $script = <<SCRIPT
sudo apt-get install flex bison build-essential csh libxaw7-dev make
wget http://spark-university.s3.amazonaws.com/stanford-compilers/vm/student-dist.tar.gz
mkdir /usr/class
sudo chown $USER /usr/class
tar xvf student-dist.tar.gz -C /usr/class
cp /usr/class/cs143/assignments/PA1/stack.cl.SKEL /usr/class/cs143/assignments/PA1/stack.cl
ln -s /usr/class/cs143/cool ~/cool
echo 'PATH=/usr/class/cs143/cool/bin:$PATH' >> ~/.bashrc
SCRIPT

  # NOTE: Don't fret if you see this error message: "stdin: is not a tty"
  # It is NOT an issue.
  # see: https://github.com/mitchellh/vagrant/issues/1673
  config.vm.provision "shell", inline: $script
end
