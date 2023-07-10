package cloud_platform.admission

ingress_with_modsec := {
  "kind": "Ingress",
  "metadata": {
    "annotations": {
      "nginx.ingress.kubernetes.io/enable-modsecurity": "true",
      "external-dns.alpha.kubernetes.io/aws-weight": "100",
      "external-dns.alpha.kubernetes.io/set-identifier": "whatever",
    }
  }
}

ingress_with_modsec_snippet := {
  "kind": "Ingress",
  "metadata": {
    "annotations": {
      "nginx.ingress.kubernetes.io/modsecurity-snippet": "whatever",
      "external-dns.alpha.kubernetes.io/aws-weight": "100",
      "external-dns.alpha.kubernetes.io/set-identifier": "whatever",
    }
  }
}

ingress_class_with_modsec := {
  "kind": "Ingress",
  "metadata": {
    "annotations": {
      "kubernetes.io/ingress.class": "nginx",
      "nginx.ingress.kubernetes.io/enable-modsecurity": "true",
      "external-dns.alpha.kubernetes.io/aws-weight": "100",
      "external-dns.alpha.kubernetes.io/set-identifier": "whatever",
    }
  }
}

ingress_class_with_modsec_snippet := {
  "kind": "Ingress",
  "metadata": {
    "annotations": {
      "kubernetes.io/ingress.class": "nginx",
      "nginx.ingress.kubernetes.io/modsecurity-snippet": "whatever",
      "external-dns.alpha.kubernetes.io/aws-weight": "100",
      "external-dns.alpha.kubernetes.io/set-identifier": "whatever",
    }
  }
}

diff_ingress_class_with_modsec := {
  "kind": "Ingress",
  "metadata": {
    "annotations": {
      "kubernetes.io/ingress.class": "some-other-ingress-class",
      "nginx.ingress.kubernetes.io/enable-modsecurity": "true",
      "nginx.ingress.kubernetes.io/modsecurity-snippet": "whatever",
      "external-dns.alpha.kubernetes.io/aws-weight": "100",
      "external-dns.alpha.kubernetes.io/set-identifier": "whatever",
    }
  }
}

test_deny_modsec_no_ingress_class {
  denied
    with input as new_admission_review("CREATE", ingress_with_modsec, null)
}

# test_deny_modsec_snippet_no_ingress_class {
#   denied
#     with input as new_admission_review("CREATE", ingress_with_modsec_snippet, null)
# }

test_deny_modsec {
  denied
    with input as new_admission_review("CREATE", ingress_class_with_modsec, null)
}

# test_deny_modsec_snippet {
#   denied
#     with input as new_admission_review("CREATE", ingress_class_with_modsec_snippet, null)
# }

test_not_deny_with_diff_ingress_class {
  not denied
    with input as new_admission_review("CREATE", diff_ingress_class_with_modsec, null)
}
