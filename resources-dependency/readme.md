# Recource dependencies


## pre-requisite

At first you need to have a kubernetes cluster with crossplane and the provider kubernetes installed


## Purpose

Observe the behavior of crosspane with resources dependencies using the requiredment 

### Starting

Start the requirement installation

```bash
kubectl create ns xplane-deps

kubectl apply -f manifests/resources-mocks/crd-kind-a.yaml
kubectl apply -f manifests/resources-mocks/crd-kind-b.yaml

kubectl apply -f manifests/xrd.yaml 
kubectl apply -f manifests/composition.yaml
```


We can now install the dependency example

```bash
kubectl apply -f sample.yaml
```



 Watch the change on the composite resource

```bash
watch -n 1 "kubectl get xdeps.ldassonville.io -o yaml dep-demo-4znpk | yq '.metadata.generation'"
```

If we let the composition reach the 

```bash
kubectl patch --type merge --subresource=status  kindas.ldassonville.io dep-demo  -p '{ "status": {"result": "res-value" }} '
```


