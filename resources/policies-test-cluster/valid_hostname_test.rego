package cloud_platform.admission

# concatenated messages produced by the deny rule
denied_msg = concat(", ", deny)

denied = denied_msg != ""

# generates a redacted AdmissionReview payload (used to mock `input`)
new_admission_review(op, newObject, oldObject) = {
  "kind": "AdmissionReview",
  "apiVersion": "admission.k8s.io/v1beta1",
  "request": {
    "kind": {
      "kind": newObject.kind
    },
    "operation": op,
    "object": newObject,
    "oldObject": oldObject
  }
}

# generates a redacted Ingress spec
new_ingress(host) = {
  "apiVersion": "extensions/v1beta1",
  "kind": "Ingress",
  "spec": {
    "rules": [{ "host": host }]
  }
}

test_invalid_host_create_notallowed {
  denied
    with input as new_admission_review("CREATE", new_ingress("${not.cluster_domain_name}"), null)
}


test_valid_host_create_allowed {
  not denied
    with input as new_admission_review("CREATE", new_ingress("${cluster_domain_name}"), null)
}
valid_hostname_test.rego