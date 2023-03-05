#!/bin/bash

echo "Installing Helm"
curl -O https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
bash manifest/helm/get-helm-3

echo "Installing Ingress Controller"
kubectl apply -f manifest/ingress-controller/dev.yaml

echo "Installing NFS for Cluster"
sudo apt install -y nfs-kernel-server
helm upgrade --install nfs-subdir-external-provisioner --namespace nfs-operator --create-namespace helmCharts/nfs-operator --values helmCharts/nfs-operator/dev.yaml 

echo "Installing Cert Manager"
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install \
  cert-manager helmCharts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set prometheus.enabled=false \
  --set installCRDs=true

echo "Installing Necessary Manifests for Cert Manager"
kubectl apply -f manifest/cert-manager/01-secret.yaml
kubectl apply -f manifest/cert-manager/02-clusterissuer.yaml
kubectl apply -f manifest/cert-manager/03-certificate.yaml

echo "Installing Dummy App"
kubectl apply -f manifest/cert-manager/04-hello-world.yaml

echo "Installing Metrics Server App"
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server --namespace kube-system helmCharts/metrics-server --values  helmCharts/metrics-server/dev.yaml --set apiService.create=true --wait

echo "Intalling Promethues Grafana"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-promethues-stack --namespace monitoring --create-namespace helmCharts/kube-prometheus-stack --values helmCharts/kube-prometheus-stack/dev.yaml 

echo "Intalling Loki"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki-stack --namespace monitoring helmCharts/loki-stack --values helmCharts/loki-stack/dev.yaml

echo "Intalling Minio"
helm upgrade --install minio --namespace minio --create-namespace helmCharts/minio --values helmCharts/minio/dev.yaml

echo "Intalling Docker Image Registry"
helm upgrade --install docker-registry --namespace container-registry --create-namespace helmCharts/docker-registry --values helmCharts/docker-registry/dev.yaml

echo "Intalling Docker UI"
helm upgrade --install docker-registry-ui --namespace container-registry --create-namespace helmCharts/docker-registry-ui/ --values helmCharts/docker-registry-ui/dev.yaml