#!/bin/bash
# scripts/rollback.sh
# Rollback to previous deployment

set -euo pipefail

ENV=${1:-staging}

echo "⏪ Rolling back deployment in: $ENV"

kubectl rollout undo deployment/app --namespace="$ENV"

echo "⏳ Waiting for rollback to complete..."
kubectl rollout status deployment/app --namespace="$ENV" --timeout=5m

echo "✅ Rollback complete!"
kubectl get pods --namespace="$ENV"
