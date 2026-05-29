#!/bin/bash
# scripts/deploy.sh
# Manual deploy helper script

set -euo pipefail

ENV=${1:-staging}
TAG=${2:-latest}
REGISTRY="ghcr.io"
IMAGE_NAME="${REGISTRY}/YOUR_ORG/cicd-demo-app"

echo "🚀 Deploying to environment: $ENV"
echo "📦 Image tag: $TAG"

# Update image in kustomize overlay
cd "$(dirname "$0")/../kubernetes/overlays/$ENV"
kustomize edit set image app="${IMAGE_NAME}:${TAG}"

# Apply manifests
echo "📋 Applying Kubernetes manifests..."
kubectl apply -k . --namespace="$ENV"

# Wait for rollout
echo "⏳ Waiting for rollout..."
kubectl rollout status deployment/app --namespace="$ENV" --timeout=5m

# Show pod status
echo "✅ Deployment complete!"
kubectl get pods --namespace="$ENV"
