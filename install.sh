#!/bin/bash


install_cluster(){
    kind create cluster --name xplaned
}


install_crossplane(){

    cat << EOF  > settings.yaml
args:
  - --debug
  - --poll-interval=5s
metrics:
  enabled: true
EOF

    # Install crossplane
    helm install crossplane \
    --namespace crossplane-system \
    --create-namespace crossplane-stable/crossplane \
    --version 1.16 \
    -f ./settings.yaml
}

install_k8s_provider(){
  
  cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-kubernetes
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.14.0
EOF


  sleep 10
  
  # Provide permissions to serviceaccount
  SA=$(kubectl -n crossplane-system get sa -o name | grep provider-kubernetes | sed -e 's|serviceaccount\/|crossplane-system:|g')
  kubectl create clusterrolebinding provider-kubernetes-admin-binding --clusterrole cluster-admin --serviceaccount="${SA}"

 cat <<EOF | kubectl apply -f -
apiVersion: kubernetes.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: provider-kubernetes
spec:
  credentials:
    source: InjectedIdentity
EOF

}


install_prometheus(){

  cat << EOF  > prometheus-settings.yaml
alertmanager:
  enabled: false
kube-state-metrics:
  enabled: true
nodeExporter:
  enabled: false
prometheus-pushgateway:
  enabled: false
prometheus-node-exporter:
  enabled: false

server:
  global:
    ## How frequently to scrape targets by default
    ##
    scrape_interval: 1s
    ## How long until a scrape request times out
    ##
    scrape_timeout: 1s
    ## How frequently to evaluate rules
    ##
    evaluation_interval: 1m
EOF


    helm install -f prometheus-settings.yaml prometheus prometheus-community/prometheus --create-namespace --namespace prometheus

    # Wait that prometheus pod are ready
    sleep 20

    export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace prometheus port-forward $POD_NAME 9090

}



echo "installing cluster"
install_cluster;

echo "installing crossplane core"
install_crossplane

sleep 30


echo "installing crossplane provider kubernetes"
install_k8s_provider


install_prometheus