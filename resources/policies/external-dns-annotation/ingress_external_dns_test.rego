package cloud_platform.admission

ingress_with_external_dns_weight_annotation := {
  "kind": "Ingress",
  "metadata": {
    "name": "ing-0",
    "namespace": "ns-0",
    "annotations": {
      "external-dns.alpha.kubernetes.io/aws-weight": "100"
    }
  }
}

ingress_with_external_dns_identifier_annotation := {
  "kind": "Ingress",
  "metadata": {
    "name": "ing-0",
    "namespace": "ns-0",
    "annotations": {
      "external-dns.alpha.kubernetes.io/set-identifier": "whatever"
    }
  }
}

ingress_with_false_ignore_annotation := {
  "kind": "Ingress",
  "metadata": {
    "name": "ing-0",
    "namespace": "ns-0",
    "annotations": {
      "cloud-platform.justice.gov.uk/ignore-external-dns-weight": "false"
    }
  }
}

ingress_with_no_external_dns_and_ignore_annotation := {
  "kind": "Ingress",
  "metadata": {
    "name": "ing-0",
    "namespace": "ns-0",
    "annotations": {}
  }
}

ingress_with_external_dns_and_ignore_annotation := {
  "kind": "Ingress",
  "metadata": {
    "name": "ing-0",
    "namespace": "ns-0",
    "annotations": {
      "external-dns.alpha.kubernetes.io/aws-weight": "100",
      "external-dns.alpha.kubernetes.io/set-identifier": "whatever",
      "cloud-platform.justice.gov.uk/ignore-external-dns-weight": "true"
    }
  }
}

ingress_with_ignore_annotation := {
  "kind": "Ingress",
  "metadata": {
    "annotations": {
      "cloud-platform.justice.gov.uk/ignore-external-dns-weight": "true"
    }
  }
}

ingress_with_both_external_dns_annotation := {
  "kind": "Ingress",
  "metadata": {
    "annotations": {
      "external-dns.alpha.kubernetes.io/aws-weight": "100",
      "external-dns.alpha.kubernetes.io/set-identifier": "whatever"
    }
  }
}


new_ingress_wrong_identifier_format(namespace, name, host,color) = {
  "apiVersion": "networking.k8s.io/v1beta1",
  "kind": "Ingress",
  "metadata": {
    "name": name,
    "namespace": namespace,
    "annotations": {
      "external-dns.alpha.kubernetes.io/aws-weight": "100",
      "external-dns.alpha.kubernetes.io/set-identifier": concat("-", [name, namespace, color,"something"])
    }
  },
  "spec": {
    "rules": [{ "host": host }]
  }
}


test_deny_ingress_with_external_dns_wrong_identifier_format {
  denied
    with input as new_admission_review("CREATE", new_ingress_wrong_identifier_format("ns-0", "ing-0", "ing-0.example.com","${cluster_color}"), null)
  
}


test_not_deny_ingress_with_external_dns_correct_identifier_format {
  not denied
    with input as new_admission_review("CREATE", new_ingress("ns-0", "ing-0", "ing-0.example.com","${cluster_color}"), null)
  
}

test_deny_ingress_with_external_dns_weight_annotation {
  denied
    with input as new_admission_review("CREATE", ingress_with_external_dns_weight_annotation, null)
}

test_deny_ingress_with_external_dns_identifier_annotation {
  denied
    with input as new_admission_review("CREATE", ingress_with_external_dns_identifier_annotation, null)
}

test_deny_ingress_with_false_ignore_annotation {
  denied
    with input as new_admission_review("CREATE", ingress_with_false_ignore_annotation, null)
}

test_deny_ingress_with_no_external_dns_and_ignore_annotation {
  denied
    with input as new_admission_review("CREATE", ingress_with_no_external_dns_and_ignore_annotation, null)
}

test_not_deny_ingress_with_external_dns_and_ignore_annotation {
  not denied
    with input as new_admission_review("CREATE", ingress_with_external_dns_and_ignore_annotation, null)
}

test_not_deny_ingress_with_ignore_annotation {
  not denied
    with input as new_admission_review("CREATE", ingress_with_ignore_annotation, null)
}

test_not_deny_ingress_with_both_external_dns_annotation {
  not denied
    with input as new_admission_review("CREATE", ingress_with_both_external_dns_annotation, null)
}
