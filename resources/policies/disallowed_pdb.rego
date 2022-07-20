package cloud_platform.admission

# This policy Disallow the following scenarios when deploying PodDisruptionBudgets or resources 
# that implement the replica subresource (e.g. Deployment, ReplicationController, ReplicaSet, StatefulSet):
#     1. Deployment of PodDisruptionBudgets with .spec.maxUnavailable == 0
#     2. Deployment of PodDisruptionBudgets with .spec.minAvailable == .spec.replicas of the resource with replica subresource
# This will prevent PodDisruptionBudgets from blocking voluntary disruptions such as node draining.

deny[{"msg": msg}] {
  input.review.kind.kind == "PodDisruptionBudget"
  pdb := input.review.object
  not valid_pdb_max_unavailable(pdb)
  msg := sprintf(
    "PodDisruptionBudget <%v> has maxUnavailable of 0, only positive integers are allowed for maxUnavailable",
    [pdb.metadata.name],
  )
}
deny[{"msg": msg}] {
  obj := input.review.object
  pdb := data.inventory.namespace[obj.metadata.namespace]["policy/v1"].PodDisruptionBudget[_]
  obj.spec.selector.matchLabels == pdb.spec.selector.matchLabels
  not valid_pdb_max_unavailable(pdb)
  msg := sprintf(
    "%v <%v> has been selected by PodDisruptionBudget <%v> but has maxUnavailable of 0, only positive integers are allowed for maxUnavailable",
    [obj.kind, obj.metadata.name, pdb.metadata.name],
  )
}
deny[{"msg": msg}] {
  obj := input.review.object
  pdb := data.inventory.namespace[obj.metadata.namespace]["policy/v1"].PodDisruptionBudget[_]
  obj.spec.selector.matchLabels == pdb.spec.selector.matchLabels
  not valid_pdb_min_available(obj, pdb)
  msg := sprintf(
    "%v <%v> has %v replica(s) but PodDisruptionBudget <%v> has minAvailable of %v, only positive integers less than %v are allowed for minAvailable",
    [obj.kind, obj.metadata.name, obj.spec.replicas, pdb.metadata.name, pdb.spec.minAvailable, obj.spec.replicas],
  )
}
valid_pdb_min_available(obj, pdb) {
  # default to -1 if minAvailable is not set so valid_pdb_min_available is always true
  # for objects with >= 0 replicas. If minAvailable defaults to >= 0, objects with
  # replicas field might violate this constraint if they are equal to the default set here
  min_available := object.get(pdb.spec, "minAvailable", -1)
  obj.spec.replicas > min_available
}
valid_pdb_max_unavailable(pdb) {
  # default to 1 if maxUnavailable is not set so valid_pdb_max_unavailable always returns true.
  # If maxUnavailable defaults to 0, it violates this constraint because all pods needs to be
  # available and no pods can be evicted voluntarily
  max_unavailable := object.get(pdb.spec, "maxUnavailable", 1)
  max_unavailable > 0
}