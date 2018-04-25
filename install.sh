#!/bin/bash
cp gate-sso.conf /var/lib/lxd/containers/$1/rootfs/etc/default/gate_sso.conf
lxc exec $1 -- sudo bash -c "curl -L https://omnitruck.chef.io/install.sh | sudo bash"
lxc exec $1 -- sudo bash -c "sudo curl -L https://raw.githubusercontent.com/gate-sso/gate-install/master/gate-install.json > /root/gate-install.json"
lxc exec $1 -- sudo bash -c "sudo chef-solo -j /root/gate-install.json --recipe-url https://github.com/gate-sso/gate-install/raw/master/chef-solo.tar.gz"
