#!/bin/bash

echo "Installing Helm"
#curl -O https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
bash manifest/get-helm-3

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

echo "Installing Ingress Controller"
kubectl apply -f manifest/ingress-controller/01-nginx-ingress-controller.yaml

echo "Installing Dummy App"
kubectl apply -f manifest/cert-manager/04-hello-world.yaml