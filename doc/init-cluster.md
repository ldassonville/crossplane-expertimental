# Cluster install


```bash
kind create cluster --name crossplane-experimental

helm install crossplane \
--namespace crossplane-system \
--create-namespace crossplane-stable/crossplane 

```bash
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-kubernetes
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.13.0
EOF
```

```bash
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


## Cluster remove

```bash
kind delete cluster --name crossplane-experimental
```


