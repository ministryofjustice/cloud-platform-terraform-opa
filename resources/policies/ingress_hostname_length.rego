package cloud_platform.admission

import data.kubernetes.ingresses

# This policy denies any ingresses with hostnames defined which exceed Route53 domain name length
# restrictions.
#
# From AWS docs:
# Domain names (including the names of domains, hosted zones, and records) consist of a series of labels separated by dots. 
# Each label can be up to 63 bytes long. The total length of a domain name cannot exceed 255 bytes, including the dots. Amazon Route 53 supports any valid domain name.


# Check total length of domain name
deny[msg] {
	input.request.kind.kind == "Ingress"
	domain := input.request.object.spec.rules[_].host
	count(domain) > 255
	msg := sprintf("\nHostname: '%v' exceeds permitted domain name length of 255 characters", [domain])
}

# Check labels length
deny[msg] {
	input.request.kind.kind == "Ingress"
	domain := input.request.object.spec.rules[_].host
	labels := split(domain, ".")
    some i
    count(labels[i]) > 63
	msg := sprintf("\nLabel '%v' in hostname: '%v' exceeds permitted length of 63 characters", [labels[i], domain])
}