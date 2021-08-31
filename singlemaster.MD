# Kubernetes

This file serves as a guide for installing, configuring and running [Kubernetes](https://kubernetes.io/) single master cluster on Ubuntu/Debian servers.

## Kubernetes setup

The following steps need to be taken on all cluster nodes if not instructed otherwise.

### Install Docker

Follow the instructions from this link: https://docs.docker.com/install/linux/docker-ce/ubuntu/ or run these commands:

    $ sudo apt update
    $ sudo apt install -y docker.io

### Add Kubernetes repository 

Replace `xenial` with your version of Ubuntu/Debian.

    $ sudo apt update
    $ sudo apt install -y apt-transport-https
    $ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

    $ echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
    $ sudo apt update

### Install Kubernetes components

Replace `1.22.1-00` with your desired version.  
   
    $ sudo apt update 
    $ sudo apt install -y kubelet=1.22.1-00 kubeadm=1.22.1-00 kubernetes-cni

### Configure swap

Kubernetes requires swap to be turned off.

    $ sudo apt install mount   #install swapoff in mount pkg
    $ sudo swapoff --all
    $ sudo systemctl mask <disk_name>.swap #in case you use systemd; e.g., disk_name=dev-sda2

### Initialize Kubernetes cluster

Run the `init` command on your **master node**:

    $ sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=<server_ip_address> --kubernetes-version stable-1.22

Replace `1.22` with installed version (from step Install Kubernetes components).  
Replace `<server_ip_address>` with your master server's IP address - this is the server where you run `init` command.  
Specified `--pod-network-cidr` remains as is for Flannel network. Other network CNIs require different ranges.  

Run `join` command on your **worker nodes**. `Join command is given as the output of the init command.` Do not forget to add **sudo**.  

    #EXAMPLE: sudo kubeadm join --token f2292a.77a85956eb6acbd6 <master_ip_address>:6443 --discovery-token-ca-cert-hash sha256:0c4890b8d174078072545ef17f295a9badc5e2041dc68c419880cca93d084098

Complete the initialization with the following (**only on master nodes**):

    $ mkdir -p $HOME/.kube
    $ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    $ sudo chown $(id -u):$(id -g) $HOME/.kube/config

Initialize one of the following network CNIs (**only on one master node**) - **recommended CNI is Flannel**:

    $ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml     # Flannel
    # kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" # Weave
    # kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml   # Calico

Check if the Kubernetes cluster is running correctly:

    $ kubectl get nodes
    
    # EXAMPLE OUTPUT
    NAME    STATUS   ROLES    AGE   VERSION
    node-01   Ready    master   44d   v1.22.1
    node-02   Ready    worker   44d   v1.22.1
    node-03   Ready    worker   44d   v1.22.1

There should be **Ready** next to all nodes. In order to describe each node use `kubectl describe node <node_name>` command.  
To label a specific node use `kubectl label nodes <node_name> <tag_name>=<tag_value>` command.  
To unlabel a specific node use `kubectl label nodes <node_name> <tag_name>-` command.  
To **enable pods on master nodes** use `kubectl taint nodes <node_name> node-role.kubernetes.io/master-`

#### Reinitialize or add new worker nodes

For reinitializing or adding new worker nodes, you need a proper `join` command. However, `token` expires after 24 hours so you need to create a new one from the **master node**:

    $ kubeadm token create    # create new token
    $ kubeadm token list      # check if the token is created

Get the number of the new token an run the following command on a new **worker node**.

    #EXAMPLE: sudo kubeadm join <master_ip_address>:6443 --token 25jm1l.mvbsh7s0jivozpdm --discovery-token-unsafe-skip-ca-verification

Detailed instructions can be found [here](https://blog.scottlowe.org/2019/07/12/calculating-ca-certificate-hash-for-kubeadm/).

### Destroying Kubernetes cluster

Run the following command on **master node** for all worker nodes:

    $ kubectl drain --force=true <worker_node> --ignore-daemonsets=true
    $ kubectl delete node <worker_node>

Run on all nodes:

    $ kubeadm reset

For complete reset after draining and deleting nodes see [this](https://stackoverflow.com/questions/46276796/kubernetes-cannot-cleanup-flannel).

For quick way, use the script from this repo on each node:

    $ sudo -i ./cleanup.sh

### Remote access

To enable remote access to your Kuberenetes cluster, first install `kubectl` on your local machine:

    $ snap install kubectl --classic

and then copy creditentials from you Kuberenetes master (replace `username` with appropriate users and `k8s_master_ip_address` with Kubernetes master IP):

    $ scp -r <username>@<k8s_master_ip_address>:/home/username/.kube $HOME/.

That should work. Run some command to test your remote connection:

    $ kubectl get nodes

## Helm setup

Run the following commands on **master node**.

### Install Helm

    $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    $ chmod 700 get_helm.sh
    $ ./get_helm.sh