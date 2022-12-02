package cloud_platform.admission

import data.kubernetes.ingresses

# This policy denies any ingresses with hostnames defined that exceed the Route53
# permitted character length for individual 'labels' within a domain name.
#
# From AWS docs:
# Domain names (including the names of domains, hosted zones, and records) consist of a series of labels separated by dots. 
# Each label can be up to 63 bytes long. The total length of a domain name cannot exceed 255 bytes, including the dots. Amazon Route 53 supports any valid domain name.
#
# Total domain name lengths do not require an OPA policy as the Ingress annotations have an enforced 253 character limit.

# Check labels length
deny[msg] {
	input.request.kind.kind == "Ingress"
	domain := input.request.object.spec.rules[_].host
	labels := split(domain, ".")
    some i
    count(labels[i]) > 63
	msg := sprintf("\nLabel '%v' in hostname: '%v' exceeds permitted length of 63 characters", [labels[i], domain])
}