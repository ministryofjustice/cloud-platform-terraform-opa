
certManager:
  enabled: false
generateCerts: true

admissionController:
  enabled: true
  kind: ValidatingWebhookConfiguration
  failurePolicy: Fail

# To restrict the kinds of operations and resources that are subject to OPA
# policy checks, see the settings below. By default, all resources and
# operations are subject to OPA policy checks.
admissionControllerRules:
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

# Docker image and tag to deploy.
image: 
  repository: openpolicyagent/opa
  tag: 0.37.0
  pullPolicy: IfNotPresent

mgmt:
  enabled: true
  image:
    repository: openpolicyagent/kube-mgmt
    tag: 4.1.0
  imagePullPolicy: IfNotPresent
  configmapPolicies:
    enabled: true
    namespaces: [opa]
  replicate:
    cluster:
      - "v1/namespaces"
    namespace:
      - "extensions/v1beta1/ingresses"
    path: kubernetes

# Number of OPA replicas to deploy. OPA maintains an eventually consistent
# cache of policies and data. If you want high availability you can deploy two
# or more replicas.
replicas: 2

podDisruptionBudget:
  enabled: true
  minAvailable: 1

rbac:
  # If true, create & use RBAC resources
  #
  create: true
  rules:
    cluster:
    - apiGroups:
        - ""
      resources:
      - configmaps
      verbs:
      - update
      - patch
      - get
      - list
      - watch
    - apiGroups:
        - ""
      resources:
      - namespaces
      verbs:
      - get
      - list
      - watch
    - apiGroups:
        - extensions
      resources:
      - ingresses
      verbs:
      - get
      - list
      - watch
