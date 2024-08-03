# Sync & Ready Status

You probably already have observed on your crossplane resource the 2 conditions **sync** and **ready**

**Example**


```yaml
status:
  # ...
  conditions:
  - lastTransitionTime: "2024-07-30T11:26:10Z"
    reason: ReconcileSuccess
    status: "True"
    type: Synced
  - lastTransitionTime: "2024-07-30T08:29:34Z"
    reason: Available
    status: "True"
    type: Ready
```


It's important to understand what they really mean to understand the behavior of your compositions / resources. 


## Synced

The synced status indicates that the reconcile method has successfully updated the managed resources 

It's not indicate that the managed resources is ready to work but only that it is well synchronized

The reasons possible for the resouces synced [conditions](https://github.com/crossplane/crossplane-runtime/blob/2d523674b5a01b1a92f974010cf55da0f6e36230/apis/common/v1/condition.go#L52-L54) are   : 

* ReconcileSuccess : The resources have been sucessfully updated
* ReconcileError : The resources have not been reconciled du to an error
* ReconcilePaused : The resources is explicitely labelized for pause the reconciliation


```yaml
status:
  conditions:
  - lastTransitionTime: "2024-07-21T11:29:21Z"
      message: 'cannot compose resources: cannot render ToComposite patches for composed
      resource "demo": cannot apply the "ToCompositeFieldPath"
      patch at index 32: status: no such field'
      reason: ReconcileError
      status: "False"
      type: Synced
```


## Ready

In this case the reconciliation have been executed totatly

the ready check is valid 

You can configure the readiness check (cf [crossplane documentation](https://docs.crossplane.io/latest/concepts/compositions/#resource-readiness-checks)) 

But the default behavior for resources of composition is to check if the condition **Type: Ready** exist and have a **Status: True** 


```yaml
status:
  # ...
  conditions:
  - lastTransitionTime: "2024-07-30T11:26:10Z"
    reason: ReconcileSuccess
    status: "True"
    type: Synced
  - lastTransitionTime: "2024-07-30T08:29:34Z"
    reason: Available
    status: "True"
    type: Ready
```





