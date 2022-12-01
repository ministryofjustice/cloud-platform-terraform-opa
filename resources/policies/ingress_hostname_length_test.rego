package cloud_platform.admission

ingress_with_valid_length_hostname := {
  "kind": "Ingress",
  "metadata": {
    "name": "helloworld",
    "annotations": {
      "external-dns.alpha.kubernetes.io/set-identifier": "helloworld-mynamespace-green",
      "external-dns.alpha.kubernetes.io/aws-weight": "100"
    }
  },
  "spec": {
    "ingressClassName": "default",
    "tls": [
      {
        "hosts": [
          "helloworld-app.apps.live.cloud-platform.service.justice.gov.uk"
        ]
      }
    ],
    "rules": [
      {
        "host": "helloworld-app.apps.live.cloud-platform.service.justice.gov.uk",
        "http": {
          "paths": [
            {
              "path": "/",
              "pathType": "ImplementationSpecific",
              "backend": {
                "service": {
                  "name": "helloworld",
                  "port": {
                    "number": 4567
                  }
                }
              }
            }
          ]
        }
      }
    ]
  }
}

test_allow_ingress_hostname_length {
  not denied
    with input as new_admission_review("CREATE", ingress_with_valid_length_hostname, null)
}
