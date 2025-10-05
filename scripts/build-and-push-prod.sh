#!/bin/bash

# VLM Demo Enterprise Production - Container Build and Push Script
# This script builds production web container and pushes it to a container registry
# Note: RHAIIS is deployed separately using rhaiis-deployment.yml

set -e

# Configuration
REGISTRY="quay.io/rh_ee_micyang"
WEB_PROD_IMAGE="vlm-demo-web-prod"
TAG="0.1"

# Build configuration
BUILD_MULTI_ARCH=${BUILD_MULTI_ARCH:-false}
PLATFORMS="linux/amd64,linux/arm64"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 VLM Demo Enterprise Production - Container Build Script${NC}"
echo -e "${PURPLE}🌐 Production Web Container Build${NC}"
echo "=============================================================="

# Check if podman or docker is available
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
    echo -e "${GREEN}✓ Using Podman${NC}"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
    echo -e "${GREEN}✓ Using Docker${NC}"
else
    echo -e "${RED}❌ Neither Podman nor Docker found. Please install one of them.${NC}"
    exit 1
fi

# Function to build and push an image
build_and_push() {
    local containerfile=$1
    local image_name=$2
    local full_image="${REGISTRY}/${image_name}:${TAG}"
    
    echo -e "\n${YELLOW}📦 Building ${image_name}...${NC}"
    echo "Containerfile: ${containerfile}"
    echo "Image: ${full_image}"
    
    if [[ "$BUILD_MULTI_ARCH" == "true" ]]; then
        echo "Building multi-architecture image for: ${PLATFORMS}"
        
        # Build multi-arch image and push
        if $CONTAINER_CMD buildx build \
            --platform "${PLATFORMS}" \
            -f "${containerfile}" \
            -t "${full_image}" \
            --push \
            .; then
            echo -e "${GREEN}✓ Successfully built and pushed multi-arch ${image_name}${NC}"
        else
            echo -e "${RED}❌ Failed to build multi-arch ${image_name}${NC}"
            echo -e "${YELLOW}💡 Make sure buildx is available and you're logged in:${NC}"
            echo "   $CONTAINER_CMD login ${REGISTRY}"
            exit 1
        fi
    else
        # Build single architecture image
        if $CONTAINER_CMD build -f "${containerfile}" -t "${full_image}" .; then
            echo -e "${GREEN}✓ Successfully built ${image_name}${NC}"
        else
            echo -e "${RED}❌ Failed to build ${image_name}${NC}"
            exit 1
        fi
        
        # Push the image
        echo -e "\n${YELLOW}📤 Pushing ${image_name}...${NC}"
        if $CONTAINER_CMD push "${full_image}"; then
            echo -e "${GREEN}✓ Successfully pushed ${image_name}${NC}"
        else
            echo -e "${RED}❌ Failed to push ${image_name}${NC}"
            echo -e "${YELLOW}💡 Make sure you're logged in to the registry:${NC}"
            echo "   $CONTAINER_CMD login ${REGISTRY}"
            exit 1
        fi
    fi
}

# Check if required files exist
if [[ ! -f "web/Containerfile.web-prod" ]] && [[ ! -f "Containerfile.web-prod" ]]; then
    echo -e "${YELLOW}⚠️  Production Containerfile not found (Containerfile.web-prod)${NC}"
    echo -e "${YELLOW}    Using web/Containerfile.web for production build${NC}"
fi

if [[ ! -f "web/prod-index.html" ]]; then
    echo -e "${RED}❌ web/prod-index.html not found${NC}"
    exit 1
fi

# Build and push production web container
echo -e "\n${PURPLE}🌐 Building Production Web Container...${NC}"
if [[ -f "web/Containerfile.web-prod" ]]; then
    build_and_push "web/Containerfile.web-prod" "${WEB_PROD_IMAGE}"
else
    build_and_push "web/Containerfile.web" "${WEB_PROD_IMAGE}"
fi

echo -e "\n${GREEN}🎉 Production web container built and pushed successfully!${NC}"
echo -e "\n${BLUE}📋 Next steps for Enterprise Production Deployment:${NC}"
echo ""
echo -e "${YELLOW}1. Deploy RHAIIS (Red Hat AI Inference Server):${NC}"
echo "   oc apply -f openshift/rhaiis-deployment.yml"
echo ""
echo -e "${YELLOW}2. Deploy production web application:${NC}"
echo "   oc apply -f openshift/openshift-deployment-prod.yaml"
echo ""
echo -e "${YELLOW}3. Check deployment status:${NC}"
echo "   oc get pods -n rhaiis"
echo "   oc get pods -n llama-guard"
echo "   oc get pods -n vlm-demo"
echo "   oc get routes -n vlm-demo"
echo ""
echo -e "${YELLOW}4. Monitor RHAIIS vLLM model loading:${NC}"
echo "   oc logs -f deployment/rhaiis -n rhaiis"
echo "   oc logs -f deployment/llama-guard -n llama-guard"
echo ""
echo -e "${YELLOW}5. Test vLLM API endpoint:${NC}"
echo "   oc port-forward service/rhaiis-service 8000:8000 -n rhaiis"
echo "   curl http://localhost:8000/v1/models"
echo ""
echo -e "${YELLOW}6. Access the production application:${NC}"
echo "   oc get route vlm-demo-route -n vlm-demo -o jsonpath='{.spec.host}'"
echo ""
echo -e "${YELLOW}📝 Production Images built:${NC}"
echo "   ${REGISTRY}/${WEB_PROD_IMAGE}:${TAG} (Production Web Application)"
echo ""
echo -e "${PURPLE}🏢 Enterprise Features:${NC}"
echo "   ✓ Red Hat AI Inference Server (RHAIIS) deployed separately"
echo "   ✓ vLLM backend for high-performance inference"
echo "   ✓ Qwen2-VL-2B-Instruct model (Vision Language Model)"
echo "   ✓ Llama-Guard-3-1B model (Content Safety Guardrails)"
echo "   ✓ Production web application with direct RHAIIS integration"
echo "   ✓ Enhanced security and resource management"
echo "   ✓ GPU time-slicing for efficient resource usage"
echo "   ✓ Network policies and security compliance"
echo ""
if [[ "$BUILD_MULTI_ARCH" == "true" ]]; then
    echo -e "${GREEN}✓ Multi-architecture build enabled (${PLATFORMS})${NC}"
else
    echo -e "${YELLOW}💡 To build multi-arch images: BUILD_MULTI_ARCH=true ./build-and-push-prod.sh${NC}"
fi
echo ""
echo -e "${GREEN}🔥 Ready for Enterprise Production Deployment!${NC}"
