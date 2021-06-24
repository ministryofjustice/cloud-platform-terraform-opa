package library.kubernetes.admission.mutating

import data.kubernetes.ingresses

# add weight to ingress if not present
patch[patchCode] {
	isValidRequest
	isCreateOrUpdate
	input.request.kind.kind == "Ingress"
  hasAnnotationValue(input.request.object, "kubernetes.io/ingress.class", "nginx")
  not hasAnnotation(input.request.object, "external-dns.alpha.kubernetes.io/aws-weight")
  patchCode = makeAnnotationPatch("add", "external-dns.alpha.kubernetes.io~1aws-weight", "100", "")
}
