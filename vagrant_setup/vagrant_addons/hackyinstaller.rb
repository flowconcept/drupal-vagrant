# -*- mode: ruby -*-
# vi: set ft=ruby :

class HackyGuestAdditionsInstaller < VagrantVbguest::Installers::Debian
  def install(opts=nil, &block)
    super
    super_garbage_hack = <<-EOF
if [ ! -e /usr/lib/VBoxGuestAdditions ]; then
  sudo ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions \
    /usr/lib/VBoxGuestAdditions || true
fi
EOF
    communicate.sudo(super_garbage_hack)
  end
end
