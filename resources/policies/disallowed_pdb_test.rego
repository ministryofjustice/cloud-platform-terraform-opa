package cloud_platform.admission

match_labels := {"matchLabels": {
  "app": "val1",
}}

test_deny_pdb_min_available_non_percent {
  denied
    with input as new_admission_review("CREATE", pdb_min_available(3), null)
}

test_deny_pdb_max_unavailable_non_percent {
  denied
    with input as new_admission_review("CREATE", pdb_max_unavailable(0), null)
}

test_not_deny_pdb_min_available_high {
  not denied
    with input as new_admission_review("CREATE", pdb_min_available("66%"), null)
}

test_not_deny_pdb_min_available_low {
  not denied
    with input as new_admission_review("CREATE", pdb_min_available("0%"), null)
}

test_deny_pdb_min_available {
  denied
    with input as new_admission_review("CREATE", pdb_min_available("88%"), null)
}

test_not_deny_pdb_max_unavailable_high {
  not denied
    with input as new_admission_review("CREATE", pdb_max_unavailable("100%"), null)
}

test_not_deny_pdb_max_unavailable_low {
  not denied
    with input as new_admission_review("CREATE", pdb_max_unavailable("33%"), null)
}

test_deny_pdb_max_unavailable {
  denied
    with input as new_admission_review("CREATE", pdb_max_unavailable("20%"), null)
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

pdb_max_unavailable(max_unavailable) = {
    "apiVersion": "policy/v1",
    "kind": "PodDisruptionBudget",
    "metadata": {
      "name": "pdb-1",
      "namespace": "namespace-1",
    },
    "spec": {
      "selector": match_labels,
      "maxUnavailable": max_unavailable,
    }
}
