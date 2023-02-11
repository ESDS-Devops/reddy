#!/bin/bash
kubeadm join 10.0.2.4:6443 --token yrzk3n.5mvuy40y23nakrcp \
	--discovery-token-ca-cert-hash sha256:7a7474306c9df436067f62b4ac5ad8e66fcbaf80724832074d25760cddb13630
#apt install -y nfs-common
