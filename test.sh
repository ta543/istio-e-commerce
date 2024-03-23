#!/bin/bash

# Define the base path for the Istio configuration files
BASE_PATH_ISTIO_CONFIG="istio-config"

# Create the directory if it doesn't exist
mkdir -p "$BASE_PATH_ISTIO_CONFIG"

# Gateway configuration
cat > "$BASE_PATH_ISTIO_CONFIG/gateway.yaml" <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: example-gateway
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
EOF

# VirtualService configuration
cat > "$BASE_PATH_ISTIO_CONFIG/virtualservice.yaml" <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: example-service
spec:
  hosts:
  - "*"
  gateways:
  - example-gateway
  http:
  - match:
    - uri:
        exact: /
    route:
    - destination:
        host: example-service
        port:
          number: 80
EOF

# DestinationRule configuration
cat > "$BASE_PATH_ISTIO_CONFIG/destinationrule.yaml" <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: example-destination
spec:
  host: example-service
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
EOF

# PeerAuthentication configuration
cat > "$BASE_PATH_ISTIO_CONFIG/peerauthentication.yaml" <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF

# AuthorizationPolicy configuration
cat > "$BASE_PATH_ISTIO_CONFIG/authorizationpolicy.yaml" <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: example-policy
spec:
  selector:
    matchLabels:
      app: example-app
  action: ALLOW
  rules:
  - to:
    - operation:
        methods: ["GET"]
EOF

echo "Istio configuration files created successfully."
