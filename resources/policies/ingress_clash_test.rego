package cloud_platform.admission

# generates a redacted Ingress spec
new_ingress(namespace, name, host,color) = {
  "apiVersion": "networking.k8s.io/v1beta1",
  "kind": "Ingress",
  "metadata": {
    "name": name,
    "namespace": namespace,
    "annotations": {
      "external-dns.alpha.kubernetes.io/aws-weight": "100",
      "external-dns.alpha.kubernetes.io/set-identifier": concat("-", [name, namespace, color])
    }
  },
  "spec": {
    "rules": [{ "host": host }]
  }
}

test_ingress_create_allowed {
  not denied
    with input as new_admission_review("CREATE", new_ingress("ns-0", "ing-1", "ing-1.example.com","${cluster_color}"), null)
    with data.kubernetes.ingresses as {
      "ns-0": {
        "ing-0": new_ingress("ns-0", "ing-0", "ing-0.example.com","${cluster_color}")
      }
    }
}

test_ingress_create_conflict {
  denied
    with input as new_admission_review("CREATE", new_ingress("ns-1", "ing-0", "ing-0.example.com","${cluster_color}"), null)
    with data.kubernetes.ingresses as {
      "ns-0": {
        "ing-0": new_ingress("ns-0", "ing-0", "ing-0.example.com","${cluster_color}")
      }
    }
}

test_ingress_update_same_host {
  not denied
    with input as new_admission_review("UPDATE", new_ingress("ns-0", "ing-0", "ing-0.example.com","${cluster_color}"), null)
    with data.kubernetes.ingresses as {
      "ns-0": {
        "ing-0": new_ingress("ns-0", "ing-0", "ing-0.example.com","${cluster_color}")
      }
    }
}

test_ingress_update_new_host {
  not denied
    with input as new_admission_review("UPDATE", new_ingress("ns-0", "ing-0", "ing-1.example.com","${cluster_color}"), null)
    with data.kubernetes.ingresses as {
      "ns-0": {
        "ing-0": new_ingress("ns-0", "ing-0", "ing-0.example.com","${cluster_color}")
      }
    }
}

test_ingress_update_existing_host {
  denied
    with input as new_admission_review("UPDATE", new_ingress("ns-1", "ing-0", "ing-1.example.com","${cluster_color}"), null)
    with data.kubernetes.ingresses as {
      "ns-0": {
        "ing-0": new_ingress("ns-0", "ing-0", "ing-0.example.com","${cluster_color}"),
        "ing-1": new_ingress("ns-0", "ing-1", "ing-1.example.com","${cluster_color}")
      }
    }
}

test_ingress_update_existing_host_other_namespace {
  denied
    with input as new_admission_review("UPDATE", new_ingress("ns-0", "ing-0", "ing-1.example.com","${cluster_color}"), null)
    with data.kubernetes.ingresses as {
      "ns-0": {
        "ing-0": new_ingress("ns-0", "ing-0", "ing-0.example.com","${cluster_color}"),
      },
      "ns-1": {
        "ing-1": new_ingress("ns-1", "ing-1", "ing-1.example.com","${cluster_color}")
      }
    }
}
