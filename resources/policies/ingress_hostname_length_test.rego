package cloud_platform.admission

ingress_test(host) = {
  "kind": "Ingress",
  "spec": {
    "ingressClassName": "default",
    "rules": [
      {
        "host": host,
      }
    ]
  }
}

test_allow_create_ingress_hostname_label_length {
  not denied
    with input as new_admission_review("CREATE", ingress_test("helloworld.apps.live.cloud-platform.service.justice.gov.uk"), null)
}

test_allow_create_ingress_hostname_at_max_label_length {
  not denied
    with input as new_admission_review("CREATE", ingress_test("this-label-is-total-sixty-three-characters-length-limit-exactly.apps.live.cloud-platform.service.justice.gov.uk"), null)
}

test_allow_update_ingress_hostname_label_length {
  not denied
    with input as new_admission_review("UPDATE", ingress_test("helloworld.apps.live.cloud-platform.service.justice.gov.uk"), null)
}

test_deny_create_ingress_hostname_label_length {
  denied
    with input as new_admission_review("CREATE", ingress_test("this-label-is-too-long-to-be-a-label-it-is-over-permitted-route53-length.apps.live.cloud-platform.service.justice.gov.uk"), null)
}

test_deny_update_ingress_hostname_label_length {
  denied
    with input as new_admission_review("UPDATE", ingress_test("this-label-is-too-long-to-be-a-label-it-is-over-permitted-route53-length.apps.live.cloud-platform.service.justice.gov.uk"), null)
}
