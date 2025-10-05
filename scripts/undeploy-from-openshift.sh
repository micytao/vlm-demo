#!/bin/bash

# Undeploy VLM Demo from OpenShift
# This script reverses the deployment process and cleans up all resources

set -e

# Configuration
NAMESPACE="${NAMESPACE:-vlm-demo}"
DELETE_NAMESPACE="${DELETE_NAMESPACE:-false}"

echo "================================================"
echo "VLM Demo - OpenShift Undeployment"
echo "================================================"
echo ""
echo "Configuration:"
echo "  App Namespace:           $NAMESPACE"
echo "  Delete Namespace:        $DELETE_NAMESPACE"
echo ""
echo "⚠️  WARNING: This will remove all VLM Demo resources from the cluster!"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v oc &> /dev/null; then
    echo "❌ Error: 'oc' CLI not found. Please install OpenShift CLI."
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "❌ Error: 'kubectl' CLI not found. Please install kubectl."
    exit 1
fi

echo "✅ CLI tools found"

# Check if logged into OpenShift
if ! oc whoami &> /dev/null; then
    echo "❌ Error: Not logged into OpenShift cluster."
    echo "   Please run: oc login <cluster-url>"
    exit 1
fi

echo "✅ Logged into OpenShift as: $(oc whoami)"

# Check if namespace exists
echo ""
echo "Checking namespace '$NAMESPACE'..."
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "ℹ️  Namespace '$NAMESPACE' does not exist. Nothing to undeploy."
    exit 0
fi

echo "✅ Namespace found: $NAMESPACE"

# Confirm before proceeding
echo ""
read -p "Are you sure you want to undeploy VLM Demo from '$NAMESPACE'? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Undeployment cancelled."
    exit 0
fi

# Delete route
echo ""
echo "Deleting route..."
if oc get route vlm-demo-route -n $NAMESPACE &> /dev/null; then
    oc delete route vlm-demo-route -n $NAMESPACE
    echo "✅ Route deleted: vlm-demo-route"
else
    echo "  Route not found, skipping"
fi

# Delete service
echo ""
echo "Deleting service..."
if kubectl get svc vlm-demo-service -n $NAMESPACE &> /dev/null; then
    kubectl delete svc vlm-demo-service -n $NAMESPACE
    echo "✅ Service deleted: vlm-demo-service"
else
    echo "  Service not found, skipping"
fi

# Delete deployment
echo ""
echo "Deleting deployment..."
if kubectl get deployment vlm-demo-app -n $NAMESPACE &> /dev/null; then
    kubectl delete deployment vlm-demo-app -n $NAMESPACE
    echo "✅ Deployment deleted: vlm-demo-app"
    
    # Wait for pods to terminate
    echo "  Waiting for pods to terminate..."
    kubectl wait --for=delete pod -l app=vlm-demo -n $NAMESPACE --timeout=120s 2>/dev/null || true
    echo "  Pods terminated"
else
    echo "  Deployment not found, skipping"
fi

# Delete namespace if requested
echo ""
if [[ "$DELETE_NAMESPACE" == "true" ]]; then
    echo "Deleting namespace '$NAMESPACE'..."
    read -p "⚠️  This will delete the entire namespace. Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        oc delete namespace $NAMESPACE
        echo "✅ Namespace deleted: $NAMESPACE"
    else
        echo "  Namespace deletion cancelled"
    fi
else
    echo "ℹ️  Namespace '$NAMESPACE' preserved (set DELETE_NAMESPACE=true to remove)"
fi

# Summary
echo ""
echo "================================================"
echo "Undeployment Successful! ✅"
echo "================================================"
echo ""
echo "Resources removed:"
echo "  ✓ Route:      vlm-demo-route"
echo "  ✓ Service:    vlm-demo-service"
echo "  ✓ Deployment: vlm-demo-app"
if [[ "$DELETE_NAMESPACE" == "true" ]]; then
    echo "  ✓ Namespace:  $NAMESPACE"
else
    echo "  - Namespace:  $NAMESPACE (preserved)"
fi
echo ""
echo "Backend Services (not affected):"
echo "  ℹ️  vLLM and Llama Guard services remain deployed"
echo "  ℹ️  To redeploy, run: ./scripts/deploy-to-openshift.sh"
echo ""
echo "Verification:"
echo "  Check remaining resources: oc get all -n $NAMESPACE"
if [[ "$DELETE_NAMESPACE" != "true" ]]; then
    echo "  Delete namespace manually:  oc delete namespace $NAMESPACE"
fi
echo ""
echo "Undeployment complete! ✅"
