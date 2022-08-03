package cloud_platform.admission

# This policy Disallow the following scenarios when deploying PodDisruptionBudgets or resources 
# that implement the replica subresource (e.g. Deployment, ReplicationController, ReplicaSet, StatefulSet):
#     1. Deployment of PodDisruptionBudgets with .spec.maxUnavailable == 0
#     2. Deployment of PodDisruptionBudgets with .spec.minAvailable == .spec.replicas of the resource with replica subresource
# This will prevent PodDisruptionBudgets from blocking voluntary disruptions such as node draining.

deny[msg] {
  input.request.kind.kind == "PodDisruptionBudget"
  pdb := input.request.object
  max_unavailable := pdb.spec.maxUnavailable
  max_unavailable == 0
  msg := sprintf(
    "PodDisruptionBudget (%v) has maxUnavailable of 0, only positive integers are allowed for maxUnavailable",
    [pdb.metadata.name]
  )
}
deny[msg] {
  obj := input.review.object
  pdb := data.inventory.namespace[obj.metadata.namespace]["policy/v1"].PodDisruptionBudget[_]
  obj.spec.selector.matchLabels == pdb.spec.selector.matchLabels
  max_unavailable := pdb.spec.maxUnavailable
  max_unavailable == 0
  msg := sprintf(
    "%v <%v> has been selected by PodDisruptionBudget <%v> but has maxUnavailable of 0, only positive integers are allowed for maxUnavailable",
    [obj.kind, obj.metadata.name, pdb.metadata.name],
  )
}
deny[{"msg": msg}] {
  obj := input.review.object
  pdb := data.inventory.namespace[obj.metadata.namespace]["policy/v1"].PodDisruptionBudget[_]
  obj.spec.selector.matchLabels == pdb.spec.selector.matchLabels
  min_available := pdb.spec.minAvailable
  obj.spec.replicas > min_available
  msg := sprintf(
    "%v <%v> has %v replica(s) but PodDisruptionBudget <%v> has minAvailable of %v, only positive integers less than %v are allowed for minAvailable",
    [obj.kind, obj.metadata.name, obj.spec.replicas, pdb.metadata.name, pdb.spec.minAvailable, obj.spec.replicas],
  )
}