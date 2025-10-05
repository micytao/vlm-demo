#!/bin/bash

# VLM Demo - Container Build and Push Script
# This script builds the web container and pushes it to a container registry

set -e

# Configuration
REGISTRY="quay.io/rh_ee_micyang"
MODEL_IMAGE="vlm-demo-model"
WEB_IMAGE="vlm-demo-web"
TAG="0.1"

# Build configuration
BUILD_MULTI_ARCH=${BUILD_MULTI_ARCH:-false}
PLATFORMS="linux/amd64,linux/arm64"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 VLM Demo - Container Build Script${NC}"
echo "================================================"

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

# Check if Containerfiles exist
if [[ ! -f "Containerfile.model" ]]; then
    echo -e "${RED}❌ Containerfile.model not found${NC}"
    exit 1
fi

if [[ ! -f "web/Containerfile.web" ]]; then
    echo -e "${RED}❌ web/Containerfile.web not found${NC}"
    exit 1
fi

if [[ ! -f "web/index.html" ]]; then
    echo -e "${RED}❌ web/index.html not found${NC}"
    exit 1
fi

# Build and push model container
build_and_push "Containerfile.model" "${MODEL_IMAGE}"

# Build and push web container
build_and_push "web/Containerfile.web" "${WEB_IMAGE}"

echo -e "\n${GREEN}🎉 All containers built and pushed successfully!${NC}"
echo -e "\n${BLUE}📋 Next steps:${NC}"
echo "1. Test locally (with platform emulation on ARM Mac):"
echo "   podman run --platform linux/amd64 -p 8080:8080 ${REGISTRY}/${MODEL_IMAGE}:${TAG}"
echo "   podman run --platform linux/amd64 -p 8000:8000 ${REGISTRY}/${WEB_IMAGE}:${TAG}"
echo ""
echo "2. Deploy to OpenShift:"
echo "   oc apply -f openshift-deployment.yaml"
echo ""
echo "3. Check deployment status:"
echo "   oc get pods -n vlm-demo"
echo "   oc get routes -n vlm-demo"
echo ""
echo "4. Access the application:"
echo "   oc get route vlm-demo-route -n vlm-demo -o jsonpath='{.spec.host}'"
echo ""
echo -e "${YELLOW}📝 Images built:${NC}"
echo "   ${REGISTRY}/${MODEL_IMAGE}:${TAG}"
echo "   ${REGISTRY}/${WEB_IMAGE}:${TAG}"
echo ""
if [[ "$BUILD_MULTI_ARCH" == "true" ]]; then
    echo -e "${GREEN}✓ Multi-architecture build enabled (${PLATFORMS})${NC}"
else
    echo -e "${YELLOW}💡 To build multi-arch images: BUILD_MULTI_ARCH=true ./build-and-push.sh${NC}"
fi
