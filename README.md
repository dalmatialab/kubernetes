# kubernetes

This repo contains tutorial how to install, configure and run [Kubernetes](https://kubernetes.io/) cluster on Ubuntu/Debian servers, yaml file to install Flannel inside Kubernetes cluster and script for Kubernetes cluster cleanup.  
There are two possible options to run cluster:

 - Single master cluster
 - Multi master cluster (HA cluster)

How to install, configure and run single master cluster read in [singlemaster.MD file](./singlemaster.MD). This setup is tested and verified multiple times.  

How to install, configure and run multi master cluster read in [multimaster.MD file](./multimaster.MD). This setup is only in testing phase.  

[Flannel.yml](./flannel.yml) file serves file to install simple overlay network that provides an easy way to configure a layer 3 network fabric designed for Kubernetes. Read more about cluster networking on [official documentation](https://kubernetes.io/docs/concepts/cluster-administration/networking/).

[Cleanup.sh](./cleanup.sh) file serves as script for Kubernetes cluster cleanup after deleting and draining nodes.
