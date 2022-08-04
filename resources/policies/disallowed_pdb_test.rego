package cloud_platform.admission

namespace := "namespace-1"

match_labels := {"matchLabels": {
  "key1": "val1",
  "key2": "val2",
}}

test_deny_pdb_0_max_unavailable {
  denied
    with input as new_admission_review("CREATE", pdb_max_unavailable(0), null)
}

test_deny_pdb_1_max_unavailable {
  not denied
    with input as new_admission_review("CREATE", pdb_max_unavailable(1), null)
}

test_deny_deployment_1_replica_pdb_1_min_available {
  denied
    with input as new_admission_review("CREATE", deployment(1), null)
    with data.kubernetes as inv_pdb_min_available(1)
}

test_not_deny_deployment_2_replicas_pdb_1_min_available {
  not denied
    with input as new_admission_review("CREATE", deployment(2), null)
    with data.kubernetes as inv_pdb_min_available(1)
}


test_deny_deployment_pdb_0_max_unavailable {
  denied
    with input as new_admission_review("CREATE", deployment(2), null)
    with data.kubernetes as inv_pdb_max_unavailable(0)
}

test_not_deny_deployment_pdb_1_max_unavailable {
  not denied
    with input as new_admission_review("CREATE", deployment(2), null)
    with data.kubernetes as inv_pdb_max_unavailable(1)
}


pdb_min_available(min_available) = {
    "apiVersion": "policy/v1",
    "kind": "PodDisruptionBudget",
    "metadata": {
      "name": "pdb-1",
      "namespace": "namespace-1",
    },
    "spec": {
      "selector": match_labels,
      "minAvailable": min_available,
    }
}

pdb_max_unavailable(max_unavailable) = output {
  output := {
    "apiVersion": "policy/v1",
    "kind": "PodDisruptionBudget",
    "metadata": {
      "name": "pdb-1",
      "namespace": "namespace-1",
    },
    "spec": {
      "selector": match_labels,
      "maxUnavailable": max_unavailable,
    },
  }
}

deployment(replicas) = output {
  output := {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
      "name": "deployment-1",
      "namespace": "namespace-1",
    },
    "spec": {
      "replicas": replicas,
      "selector": match_labels,
    },
  }
}

kubernetes(obj) = output {
  output := {"namespaces": {namespace: {obj.apiVersion: {obj.kind: [obj]}}}}
}

inv_pdb_min_available(min_available) = output {
  pdb = pdb_min_available(min_available)
  output := kubernetes(pdb)
}

inv_pdb_max_unavailable(max_unavailable) = output {
  pdb = pdb_max_unavailable(max_unavailable)
  output := kubernetes(pdb)
}