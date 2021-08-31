kubeadm reset --force
systemctl stop kubelet
systemctl stop docker
rm -rf /var/lib/cni/
rm -rf /var/lib/kubelet/*
rm -rf /run/flannel
rm -rf /etc/cni/
ifconfig cni0 down
brctl delbr cni0
ifconfig flannel.1 down
ip link delete cni0
ip link delete flannel.1
systemctl start docker