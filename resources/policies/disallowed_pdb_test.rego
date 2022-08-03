package cloud_platform.admission

new_pdb_max_unavailable(max_unavailable) = {
  "apiVersion": "policy/v1",
  "kind": "PodDisruptionBudget",
  "metadata": {
    "name": "pdb-1",
    "namespace": "namespace-1",
  },
  "spec": {
    "selector": {
      "matchLabels": {
        "key1": "val1",
        "key2": "val2",
      },
    },
    "maxUnavailable": max_unavailable,
  }
}


new_deployment(replicas) = {
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "deployment-1",
    "namespace": "namespace-1",
  },
  "spec": {
    "replicas": replicas,
    "tolerations": {
      "operator": "exists", 
      "effect": "NoSchedule"
    },
    "selector": {
      "matchLabels": {
        "key1": "val1",
        "key2": "val2",
      },
    },
  }
}

test_deny_pdb_0_max_unavailable {
  denied
    with input as new_admission_review("CREATE", new_pdb_max_unavailable(0), null)
}

test_deny_pdb_1_max_unavailable {
  not denied
    with input as new_admission_review("CREATE", new_pdb_max_unavailable(1), null)
}

test_deny_deployment_1_replica_pdb_1_max_unavailable {
  denied
    with input as new_admission_review("CREATE", new_deployment(1), null)
    with data.kubernetes.PodDisruptionBudgets as {
      "pdb-1": new_pdb_max_unavailable(1)
    }
}

