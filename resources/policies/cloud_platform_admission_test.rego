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
