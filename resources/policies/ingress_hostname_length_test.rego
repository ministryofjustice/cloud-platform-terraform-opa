package cloud_platform.admission

ingress_deny_label_length := {
  "kind": "Ingress",
  "spec": {
    "ingressClassName": "default",
    "rules": [
      {
        "host": "this-label-is-too-long-to-be-a-label-it-is-over-permitted-route53-length.apps.live.cloud-platform.service.justice.gov.uk",
      }
    ]
  }
}

test_deny_ingress_hostname_label_length {
  denied
    with input as new_admission_review("CREATE", ingress_deny_label_length, null)
}