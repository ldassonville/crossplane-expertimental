
# Installation


We can found the installion options in the crossplane  [documentation](https://docs.crossplane.io/latest/software/install/#customize-the-crossplane-helm-chart)


## Cluster installation
We will start by creating a kubernetes cluster using kind
```bash
# Create the kubernetes cluster using kind
kind create cluster --name xplaned
```


## Crossplane installation
And after processing to the crossplane installation with the poll-interval to 5 secondes 

```bash
# Generate the values file for configure the crossplane helm installation 
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
```

In order to test it we will use the kubernetes provider

```bash
# Install the provider kubernetes

cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-kubernetes
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.14.0
EOF

# Provide permistion to serviceaccount
SA=$(kubectl -n crossplane-system get sa -o name | grep provider-kubernetes | sed -e 's|serviceaccount\/|crossplane-system:|g')
kubectl create clusterrolebinding provider-kubernetes-admin-binding --clusterrole cluster-admin --serviceaccount="${SA}"
```



```bash
cat <<EOF | kubectl apply -f -
apiVersion: kubernetes.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: provider-kubernetes
  namespace: crossplane-system
spec:
  credentials:
    source: InjectedIdentity
EOF
```

We now can verifiy the pod configuration using the command
```bash
POD_NAME=$(kubectl get pod -n crossplane-system -l app=crossplane -o name);  kubectl get -o yaml -n crossplane-system $POD_NAME | yq '.spec.containers[0].args'
```



## Monitoring installation

### Install prometheus


```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```


```bash

##
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


export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace prometheus port-forward $POD_NAME 9090
```


You can now open prometheus using this link : http://localhost:9090/graph




## Cluster remove

It's time to clean up ! so to destroy the cluster you can run the following command

```bash
kind delete cluster --name xplaned
```
