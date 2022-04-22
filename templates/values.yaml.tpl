opa: false

certManager:
  enabled: false

# Expose the prometheus scraping endpoint
prometheus:
  enabled: true

admissionController:
  enabled: true
  kind: ValidatingWebhookConfiguration
  failurePolicy: Fail
  namespaceSelector:
    matchExpressions:
      - {key: openpolicyagent.org/webhook, operator: NotIn, values: [ignore]}
  # To restrict the kinds of operations and resources that are subject to OPA
  # policy checks, see the settings below. By default, all resources and
  # operations are subject to OPA policy checks.
  rules:
    - operations: ["CREATE", "UPDATE"]
      apiGroups: ["extensions", "networking.k8s.io"]
      apiVersions: ["*"]
      resources: ["ingresses"]
    - operations: ["CREATE", "UPDATE"]
      apiGroups: [""]
      apiVersions: ["v1"]
      resources: ["services"]
    - operations: ["CREATE", "UPDATE"]
      apiGroups: [""]
      apiVersions: ["v1"]
      resources: ["pods"]

generateCerts: true

podDisruptionBudget:
  enabled: true
  minAvailable: 1

# Docker image and tag to deploy.
image: openpolicyagent/opa
imageTag: 0.38.1
imagePullPolicy: IfNotPresent

mgmt:
  enabled: true
  image: openpolicyagent/kube-mgmt
  imageTag: 4.1.0
  imagePullPolicy: IfNotPresent
  configmapPolicies:
    enabled: true
    namespaces: [opa]
  replicate:
    cluster:
      - "v1/namespaces"
    namespace:
      - "extensions/v1beta1/ingresses"
      - "networking.k8s.io/v1/ingresses"
    path: kubernetes

# Number of OPA replicas to deploy. OPA maintains an eventually consistent
# cache of policies and data. If you want high availability you can deploy two
# or more replicas.
replicas: 2

rbac:
  create: false
serviceAccount:
  create: false
  name: opa

securityContext:
  enabled: true
  runAsNonRoot: true
  runAsUser: 1
