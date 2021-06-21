package cloud_platform.admission

import data.kubernetes.ingresses

# Entry point to the policy. This is queried by the Kubernetes apiserver.
main = {
    "apiVersion": "admission.k8s.io/v1beta1",
    "kind": "AdmissionReview",
    "response": response,
}

# If no other responses are defined, allow the request.
default response = {
    "allowed": true
}

# Mutate the request if any there are any patches.
response = {
    "allowed": true,
    "patchType": "JSONPatch",
    "patch": base64url.encode(json.marshal(patches)),
} {
    patches := [p | p := patch[_][_]] # iterate over all patches and generate a flattened array
    count(patches) > 0
}

# Note: patch generates a _set_ of arrays. The ordering of the set is not defined.
# If you need to define ordering across patches, generate them inside the same rule.
patch[[
    {
        "op": "add",
        "path": "/metadata/annotations/external-dns.alpha.kubernetes.io~set-identifier",
        "value": "raz-test",
    },
    {
        "op": "add",
        "path": "/metadata/annotations/external-dns.alpha.kubernetes.io~aws-weight",
        "value": "100",
    }
]] {
    
    # Only apply mutations to objects in create/update operations (not
    # delete/connect operations.)
    is_create_or_update

    # only for ingresses
    input.request.kind.kind == "Ingress"

    # of type nginx
    input.request.object.metadata.annotations["kubernetes.io/ingress.class"] == "nginx"
}

is_create_or_update { is_create }
is_create_or_update { is_update }
is_create { input.request.operation == "CREATE" }
is_update { input.request.operation == "UPDATE" }

