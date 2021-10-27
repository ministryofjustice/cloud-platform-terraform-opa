package cloud_platform.admission

new_ingress_forbidden_snippet_value(namespace, name, host, forbidden_value) = {
  "apiVersion": "networking.k8s.io/v1beta1",
  "kind": "Ingress",
  "metadata": {
    "name": name,
    "namespace": namespace,
    "annotations": {
      "kubernetes.io/ingress.class": "modsec-01",
      "nginx.ingress.kubernetes.io/auth-snippet": forbidden_value,
      "nginx.ingress.kubernetes.io/configuration-snippet": forbidden_value,
      "nginx.ingress.kubernetes.io/server-snippet": forbidden_value,
      "nginx.ingress.kubernetes.io/modsecurity-snippet": forbidden_value,
      "cloud-platform.justice.gov.uk/ignore-external-dns-weight": "true"
    }
  },
  "spec": {
    "rules": [{ "host": host }]
  }
}

test_deny_ingress_with_forbidden_auth_snippet {
  denied
    with input as new_admission_review("CREATE", new_ingress_forbidden_snippet_value("ns-0", "ing-0", "ing-0.example.com", "_lua"), null)
}

test_deny_ingress_with_forbidden_configuration_snippet {
  denied
    with input as new_admission_review("CREATE", new_ingress_forbidden_snippet_value("ns-0", "ing-0", "ing-0.example.com", "root"), null)
}

test_deny_ingress_with_forbidden_server_snippet {
  denied
    with input as new_admission_review("CREATE", new_ingress_forbidden_snippet_value("ns-0", "ing-0", "ing-0.example.com", "load_module"), null)
}

test_deny_ingress_with_forbidden_modsec_snippet {
  denied
    with input as new_admission_review("CREATE", new_ingress_forbidden_snippet_value("ns-0", "ing-0", "ing-0.example.com", "kubernetes.io"), null)
}

test_not_deny_ingress_with_valid_auth_snippet {
  not denied
    with input as new_admission_review("CREATE", new_ingress_forbidden_snippet_value("ns-0", "ing-0", "ing-0.example.com", "valid"), null)
}

test_not_deny_ingress_with_valid_server_snippet {
  not denied
    with input as new_admission_review("CREATE", new_ingress_forbidden_snippet_value("ns-0", "ing-0", "ing-0.example.com", "good"), null)
}

test_not_deny_ingress_with_valid_configuration_snippet {
  not denied
    with input as new_admission_review("CREATE", new_ingress_forbidden_snippet_value("ns-0", "ing-0", "ing-0.example.com", "nice"), null)
}

test_not_deny_ingress_with_valid_modsec_snippet {
  not denied
    with input as new_admission_review("CREATE", new_ingress_forbidden_snippet_value("ns-0", "ing-0", "ing-0.example.com", "correct"), null)
}