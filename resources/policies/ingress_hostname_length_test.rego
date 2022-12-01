package cloud_platform.admission

ingress_with_valid_length_hostname := {
  "kind": "Ingress",
  "spec": {
    "ingressClassName": "default",
    "rules": [
      {
        "host": "helloworld-app.apps.live.cloud-platform.service.justice.gov.uk",
      }
    ]
  }
}

ingress_deny_length_hostname := {
  "kind": "Ingress",
  "spec": {
    "ingressClassName": "default",
    "rules": [
      {
        "host": "this-domain-name-length-exceeded.domain-name-length-exceeded.domain-name-length-exceeded.domain-name-length-exceeded.domain-name-length-exceeded.domain-name-length-exceeded.domain-name-length-exceeded.domain-name-length-exceeded.domain-name-length-exceeded.example.com",
      }
    ]
  }
}

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

test_not_deny_ingress_hostname_length {
  not denied
    with input as new_admission_review("CREATE", ingress_with_valid_length_hostname, null)
}

test_deny_ingress_hostname_length {
  denied
    with input as new_admission_review("CREATE", ingress_deny_length_hostname, null)
}

test_deny_ingress_hostname_label_length {
  denied
    with input as new_admission_review("CREATE", ingress_deny_label_length, null)
}