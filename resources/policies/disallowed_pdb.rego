package cloud_platform.admission

# This policy Disallow the following scenarios when deploying PodDisruptionBudgets:
#     1. PodDisruptionBudgets with .spec.maxUnavailable or .spec.minAvailable is not a %
#     2. PodDisruptionBudgets with .spec.minAvailable or .spec.maxUnavailable is within the limits mentioned
# This will prevent PodDistruptionBudgets to have disruptionAllowed = 0 and thereby prevent from blocking 
# voluntary disruptions such as node draining.

operations = {"CREATE", "UPDATE"}

allowed_percentage = {
	"minAvailable": [0, 66],
	"maxUnavailable": [33, 100],
}

# Deny if minAvailable or maxUnavailable is not specified as a percentage (e.g., they used an absolute.)
deny[msg] {
  input.request.kind.kind == "PodDisruptionBudget"
  operations[input.request.operation]
	allowed_percentage[field]
  obj := input.request.object
	value := obj.spec[field]
	[_, false] = get_percentage(value)
  msg := sprintf(
    "PodDisruptionBudget (%v) Value (%v) for %v not in percentage. Only percentage is allowed",
    [obj.metadata.name, value, field]
  )
}

# Deny if minAvailable or maxUnAvailable values are a percentage that is out-of-range.
deny[msg] {
	input.request.kind.kind == "PodDisruptionBudget"
  operations[input.request.operation]
	range := allowed_percentage[field]
  obj := input.request.object
	[percent, true] = get_percentage(obj.spec[field])
	# Verify the percentage is within the given range
	not within_range(percent, range)
  msg := sprintf(
    "PodDisruptionBudget (%v) Value (%v) for %v not within range %v%%-%v%%",
    [obj.metadata.name, percent, field, range[0], range[1]]
  )
}

within_range(x, [mininum, maximum]) {
	x >= mininum
	x <= maximum
}

# get_percentage gets a value and returns numeric percentage value 
# and a boolean value indicating whether the
# input value could be converted to a numeric percentage.
get_percentage(value) = [0, false] {
	not is_string(value)
}
else = [0, false] {
	not contains(value, "%")
}
else = [percent, true] {
	percent := to_number(trim(value, "%"))
}