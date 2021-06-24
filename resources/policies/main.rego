package cloud_platform.admission

main = {
  "apiVersion": "admission.k8s.io/v1beta1",
  "kind": "AdmissionReview",
  "response": response,
}

# non-patch response i.e. validation response
response = x {
	count(patch) == 0

	x := {
		"allowed": false,
		"uid": response_uid,
		"status": {"reason": reason},
	}

	reason = concat(", ", deny)
	reason != ""
}

# patch response i.e. mutating respone
else = x {
	count(patch) > 0

	# if there are missing leaves e.g. trying to add a label to something that doesn't
	# yet have any, we need to create the leaf nodes as well

	fullPatches := ensureParentPathsExist(cast_array(patch))

	x := {
		"allowed": true,
		"uid": response_uid,
		"patchType": "JSONPatch",
		"patch": base64.encode(json.marshal(fullPatches)),
	}
}

# default response
else = x {
	x := {
		"allowed": true,
		"uid": response_uid,
	}
}

isValidRequest {
	# not sure if this might be a race condition, it might get called before
	# all the validation rules have been run
	count(deny) == 0
}

isCreateOrUpdate {
	isCreate
}

isCreateOrUpdate {
	isUpdate
}

isCreate {
	input.request.operation == "CREATE"
}

isUpdate {
	input.request.operation == "UPDATE"
}
