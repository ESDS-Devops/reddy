#!/bin/bash

echo "Installing Helm"
curl -O https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
bash manifest/get-helm-3

echo "Installing Ingress Controller"
kubectl apply -f manifest/ingress-controller/01-nginx-ingress-controller.yaml

echo "Installing NFS for Cluster"
sudo apt install -y nfs-kernel-server
helm upgrade --install nfs-subdir-external-provisioner --namespace nfs-operator --create-namespace helmCharts/nfs-operator

echo "Installing Cert Manager"
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
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
helm upgrade --install metrics-server --namespace kube-system helmCharts/metrics-server --set apiService.create=true

echo "Intalling Promethues Grafana"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-promethues-stack --namespace monitoring --create-namespace helmCharts/kube-prometheus-stack --values helmCharts/kube-prometheus-stack/dev.yaml 

echo "Intalling Loki"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki-stack --namespace monitoring helmCharts/loki-stack --values helmCharts/loki-stack/dev.yaml
