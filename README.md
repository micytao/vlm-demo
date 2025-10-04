# SmolVLM Real-time Camera Demo

![demo](./demo.png)

This repository is a modern demo for how to use leading AI inference engine (llama.cpp and vLLM) with SmolVLM 500M to get real-time object detection from your camera feed. The demo provides a beautiful, responsive web interface that captures camera frames and sends them to the SmolVLM model for analysis.

## Features

- 🎥 **Real-time camera feed processing** with smart endpoint detection
- 🎨 **Modern, responsive UI** with dark/light mode toggle
- 🤖 **Customizable AI instructions** with preset options
- ⏱️ **Adjustable frame capture intervals** (100ms to 2s)
- 🌐 **Web-based interface** with professional styling
- 🚀 **Multiple deployment options** (local, container, OpenShift)
- 📱 **Mobile-friendly design** with touch support
- ⌨️ **Keyboard shortcuts** (Spacebar to start/stop, Escape to stop)
- 🔧 **Smart API endpoint management** with preset buttons

## Deployment Options

Choose the deployment method that best fits your needs:

### 🖥️ Local Development Setup

Perfect for development and testing on your local machine.

#### Prerequisites
- [llama.cpp](https://github.com/ggml-org/llama.cpp) installed with CUDA support (recommended)
- A modern web browser with camera access
- NVIDIA GPU with CUDA drivers (optional but recommended for performance)

#### Setup Instructions

1. **Install llama.cpp with CUDA support**
   
   **Option A: Download pre-built binaries (Recommended)**
   - Visit the [llama.cpp releases page](https://github.com/ggml-org/llama.cpp/releases)
   - Download the CUDA-enabled binary for your system
   - Extract and add to your PATH
   
   **Option B: Build from source with CUDA**
   ```bash
   git clone https://github.com/ggml-org/llama.cpp.git
   cd llama.cpp
   # Build with CUDA support
   make LLAMA_CUDA=1 llama-server
   ```
   
   **Option C: Using package managers**
   ```bash
   # On macOS with Homebrew (CPU only)
   brew install llama.cpp
   
   # For CUDA support, build from source or use pre-built binaries
   ```

2. **Start the model server**
   
   **Using llama.cpp (Recommended):**
   ```bash
   # Basic command (CPU only)
   llama-server -hf ggml-org/SmolVLM-500M-Instruct-GGUF --port 8080 --host 0.0.0.0
   
   # With GPU acceleration (CUDA)
   llama-server -hf ggml-org/SmolVLM-500M-Instruct-GGUF --port 8080 --host 0.0.0.0 -ngl 999
   ```
   
   **Notes:**
   - The server runs on port 8080 by default
   - Add `-ngl 999` to enable maximum GPU acceleration (NVIDIA CUDA)
   - Use `--host 0.0.0.0` to allow external connections
   - You can try other models from [here](https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal.md)
   - First run will download the model (~2GB for SmolVLM)
   - llama.cpp provides OpenAI-compatible API endpoints

3. **Open the web interface**
   ```bash
   # Simply open index.html in your browser
   open index.html
   ```

4. **Start using the demo**
   - Grant camera permissions when prompted
   - The API endpoint will be automatically detected or you can use preset buttons
   - Toggle between light and dark mode using the theme button
   - Optionally modify the instruction (e.g., "Describe what you see in JSON format")
   - Adjust the capture interval (default: 500ms)
   - Use keyboard shortcuts: Spacebar to start/stop, Escape to stop
   - Click "Start Processing" and enjoy real-time AI vision!

---

### 🐳 Local Container Deployment

Run the complete stack using two separate containers - one for the AI model and one for the web interface.

#### Prerequisites
- Podman or Docker installed
- 4GB+ RAM available
- 2+ CPU cores recommended

#### Quick Start

**Option A: Use pre-built images (Recommended)**
```bash
# Start the model container (AI backend)
podman run -d -p 8080:8080 --name smolvlm-model quay.io/rh_ee_micyang/smolvlm-model:0.1

# Start the web container (frontend)
podman run -d -p 8000:8000 --name smolvlm-web quay.io/rh_ee_micyang/smolvlm-web:0.1

# Note: ARM64 images are not currently available - use Option B to build from source
```

**Option B: Build from source**
1. **Build both containers**
   ```bash
   # Build model container
   podman build -f Containerfile.model -t smolvlm-model:latest .
   
   # Build web container
   podman build -f Containerfile.web -t smolvlm-web:latest .
   ```

2. **Run both containers**
   ```bash
   # Start the model container (AI backend)
   podman run -d -p 8080:8080 --name smolvlm-model smolvlm-model:latest
   
   # Start the web container (frontend)
   podman run -d -p 8000:8000 --name smolvlm-web smolvlm-web:latest
   ```

3. **Access the demo**
   - Open http://localhost:8000 in your browser
   - Grant camera permissions
   - Start detecting objects!

#### Two-Container Architecture
The deployment uses separate containers for better resource management:
- **Model Container**: Runs llama.cpp server with CUDA-enabled SmolVLM model on port 8080
- **Web Container**: Serves the modern HTML frontend on port 8000 and proxies API calls to the model container
- **Modern UI**: Features dark/light mode, responsive design, and smart endpoint detection
- **Security**: Both containers run as non-root users for enhanced security

#### Container Management

```bash
# View logs
podman logs -f smolvlm-model
podman logs -f smolvlm-web

# Stop both containers
podman stop smolvlm-model smolvlm-web

# Remove both containers
podman rm smolvlm-model smolvlm-web

# Remove the images
podman rmi smolvlm-model:latest smolvlm-web:latest
```

---

### ☁️ OpenShift Deployment

Deploy to OpenShift for production use with automatic scaling and management using a two-container architecture.

#### Prerequisites
- Access to an OpenShift cluster
- `oc` CLI tool installed and configured
- Container registry access (e.g., Quay.io)

#### Architecture Overview
The OpenShift deployment uses two separate containers:
1. **Model Container**: Runs llama.cpp server with CUDA-enabled SmolVLM model
2. **Web Container**: Serves the frontend and proxies API calls

#### Deployment Steps

1. **Build and push container images**
   
   **Option A: Use the provided build script (Recommended)**
   ```bash
   # Login to your container registry
   podman login quay.io
   
   # Build and push both containers
   ./build-and-push.sh
   ```
   
   **Option B: Manual build**
   ```bash
   # Build model container
   podman build -f Containerfile.model -t quay.io/your-username/smolvlm-model:latest .
   podman push quay.io/your-username/smolvlm-model:latest
   
   # Build web container
   podman build -f Containerfile.web -t quay.io/your-username/smolvlm-web:latest .
   podman push quay.io/your-username/smolvlm-web:latest
   ```

2. **Update the deployment configuration**
   
   Edit `openshift-deployment.yaml` and update the image references if using your own registry:
   ```yaml
   # Model container image
   image: quay.io/your-username/smolvlm-model:latest
   
   # Web container image  
   image: quay.io/your-username/smolvlm-web:latest
   ```

3. **Deploy to OpenShift**
   ```bash
   # Create a new project (optional)
   oc new-project smolvlm-demo
   
   # Deploy the application
   oc apply -f openshift-deployment.yaml
   
   # Check deployment status
   oc get pods -n smolvlm-demo
   oc get services -n smolvlm-demo
   oc get routes -n smolvlm-demo
   ```

4. **Access the application**
   ```bash
   # Get the route URL
   oc get route smolvlm-demo-route -n smolvlm-demo -o jsonpath='{.spec.host}'
   
   # Access the demo using the provided HTTPS URL
   ```

#### OpenShift Features
- **Two-Container Architecture**: Separate model and web containers for better resource management
- **Automatic HTTPS**: Routes provide SSL termination
- **High Availability**: Automatic pod restart and health checks
- **Resource Management**: Optimized resource allocation per container type
- **Scaling**: Web containers can scale independently from model containers
- **Security**: Non-root containers, network policies, and security contexts
- **API Proxying**: Nginx handles CORS and proxies API calls between containers

#### Monitoring and Troubleshooting

```bash
# Check application logs
oc logs -f deployment/smolvlm-model -n smolvlm-demo
oc logs -f deployment/smolvlm-web -n smolvlm-demo

# Check pod status
oc describe pod -l app=smolvlm-model -n smolvlm-demo
oc describe pod -l app=smolvlm-web -n smolvlm-demo

# Scale the web deployment (model typically stays at 1 replica)
oc scale deployment/smolvlm-web --replicas=3 -n smolvlm-demo

# Update deployments
oc rollout restart deployment/smolvlm-model -n smolvlm-demo
oc rollout restart deployment/smolvlm-web -n smolvlm-demo

# Check service connectivity
oc port-forward service/smolvlm-model-service 8080:8080 -n smolvlm-demo
oc port-forward service/smolvlm-web-service 8000:80 -n smolvlm-demo
```

---

### 🏢 Enterprise Production Deployment

For enterprise production environments, this demo includes a specialized deployment using Red Hat AI Inference Server (RHAIIS) with vLLM backend for high-performance inference.

#### Prerequisites
- Access to an OpenShift cluster with GPU nodes
- Red Hat AI Inference Server (RHAIIS) subscription
- `oc` CLI tool installed and configured
- Container registry access (e.g., Quay.io)
- Hugging Face token for model access

#### Enterprise Architecture
The enterprise production deployment uses a sophisticated architecture:
1. **RHAIIS Container**: Red Hat AI Inference Server with vLLM backend running SmolVLM-500M-Instruct
2. **Production Web Container**: Optimized frontend with direct RHAIIS integration
3. **Separate Namespaces**: `rhaiis` for the AI service, `smolvlm-demo-prod` for the web application
4. **GPU Acceleration**: NVIDIA GPU support for high-performance inference
5. **Enterprise Security**: Enhanced security policies, resource management, and compliance

#### Deployment Steps

1. **Build and push production container images**
   
   ```bash
   # Login to your container registry
   podman login quay.io
   
   # Build and push production web container
   ./build-and-push-prod.sh
   ```

2. **Deploy RHAIIS (Red Hat AI Inference Server)**
   
   ```bash
   # Create RHAIIS namespace and deploy the AI inference service
   oc apply -f rhaiis-deployment.yml
   
   # Monitor RHAIIS deployment and model loading (this takes 5-10 minutes)
   oc logs -f deployment/rhaiis -n rhaiis
   
   # Wait for the model to be fully loaded
   oc get pods -n rhaiis
   ```

3. **Deploy production web application**
   
   ```bash
   # Deploy the production web frontend
   oc apply -f openshift-deployment-prod.yaml
   
   # Check deployment status
   oc get pods -n smolvlm-demo-prod
   oc get routes -n smolvlm-demo-prod
   ```

4. **Verify the deployment**
   
   ```bash
   # Test RHAIIS vLLM API endpoint
   oc port-forward service/rhaiis-service 8000:8000 -n rhaiis
   curl http://localhost:8000/v1/models
   
   # Get the production application URL
   oc get route smolvlm-demo-prod-main-route -n smolvlm-demo-prod -o jsonpath='{.spec.host}'
   ```

#### Enterprise Features

- **🚀 High-Performance Inference**: vLLM backend with GPU acceleration
- **🔒 Enterprise Security**: Enhanced security contexts, network policies, and compliance
- **📈 Horizontal Pod Autoscaling**: Automatic scaling based on demand
- **🏗️ Resource Management**: Optimized resource allocation with requests and limits
- **🔄 High Availability**: Multi-replica deployments with health checks
- **📊 Monitoring & Observability**: Comprehensive logging and metrics
- **🌐 Production-Ready**: SSL termination, proper CORS handling, and error management
- **🎯 GPU Optimization**: NVIDIA GPU support for maximum performance
- **🔐 Secret Management**: Secure handling of API tokens and credentials

#### Production Configuration

**RHAIIS Configuration:**
- **Model**: SmolVLM-500M-Instruct via Hugging Face
- **Backend**: vLLM for high-performance inference
- **GPU**: NVIDIA GPU acceleration (1 GPU per pod)
- **Storage**: 50Gi persistent volume for model caching
- **Resources**: 8Gi RAM, 4 CPU cores, 1 GPU

**Production Web Configuration:**
- **Replicas**: 3 pods for high availability
- **Resources**: 512Mi RAM, 500m CPU per pod
- **Autoscaling**: HPA with CPU and memory targets
- **Security**: Non-root containers, security contexts
- **Networking**: Proper service mesh integration

#### Monitoring and Management

```bash
# Monitor RHAIIS model loading and inference
oc logs -f deployment/rhaiis -n rhaiis

# Check production web application logs
oc logs -f deployment/smolvlm-web-prod -n smolvlm-demo-prod

# Scale production web application
oc scale deployment/smolvlm-web-prod --replicas=5 -n smolvlm-demo-prod

# Check resource usage
oc top pods -n rhaiis
oc top pods -n smolvlm-demo-prod

# Monitor HPA status
oc get hpa -n smolvlm-demo-prod

# Check network policies
oc get networkpolicy -n rhaiis
oc get networkpolicy -n smolvlm-demo-prod
```

#### Performance Optimization

- **GPU Acceleration**: RHAIIS utilizes NVIDIA GPUs for maximum inference speed
- **Model Caching**: Persistent volumes cache the model for faster startup
- **Connection Pooling**: Optimized HTTP connections between services
- **Resource Limits**: Proper resource allocation prevents resource contention
- **Horizontal Scaling**: Web frontend scales independently from AI backend

#### Troubleshooting

```bash
# Check RHAIIS model loading status
oc describe pod -l app=rhaiis -n rhaiis

# Test vLLM API connectivity
oc port-forward service/rhaiis-service 8000:8000 -n rhaiis
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "SmolVLM-500M-Instruct", "messages": [{"role": "user", "content": "Hello"}]}'

# Check cross-namespace connectivity
oc exec -it deployment/smolvlm-web-prod -n smolvlm-demo-prod -- \
  curl http://rhaiis-service.rhaiis.svc.cluster.local:8000/v1/models

# Restart services if needed
oc rollout restart deployment/rhaiis -n rhaiis
oc rollout restart deployment/smolvlm-web-prod -n smolvlm-demo-prod
```

## Usage Guide

### Modern Interface Features

1. **Camera Access**: Grant browser permission to access your camera
2. **Theme Toggle**: Switch between light and dark mode using the moon/sun icon
3. **Smart API Endpoint**: 
   - Automatically detects environment (local file vs server)
   - Use preset buttons: "Local:8080", "Ollama", or "Clear"
   - Manual entry supported with helpful placeholder text
4. **Customize Instructions**: Modify the prompt to get different types of responses:
   - "What do you see?" (default)
   - "Describe the scene in detail"
   - "List all visible objects in JSON format"
   - "What colors are prominent in this image?"
5. **Adjust Interval**: Control how frequently frames are captured (100ms to 2s)
6. **Keyboard Shortcuts**: 
   - **Spacebar**: Start/stop processing
   - **Escape**: Stop processing
7. **Status Indicators**: Visual feedback with icons and colors
8. **Responsive Design**: Works on desktop, tablet, and mobile devices

## Performance Considerations

- **Model Loading**: First startup takes 2-5 minutes to download the model
- **Hardware Requirements**: 
  - Local Development: 4GB RAM, 2 CPU cores minimum
  - Container Deployment: 4GB RAM, 2 CPU cores minimum (as configured)
  - OpenShift Production: 4-8GB RAM, 2-4 CPU cores, 1 GPU (configurable limits)
  - NVIDIA GPU with CUDA support significantly improves performance
- **Network**: Stable internet connection required for model download
- **Browser**: Modern browsers with WebRTC support required

## Troubleshooting

### Common Issues

1. **Camera not working**: Ensure HTTPS access and grant browser permissions
2. **Model loading slowly**: First run downloads ~2GB model; subsequent runs are faster
3. **High CPU usage**: Enable GPU acceleration with `-ngl 999` for CUDA GPUs
4. **CORS errors**: Use the container deployment for proper CORS handling

### Getting Help

- Check the logs for error messages
- Ensure all prerequisites are installed
- Verify network connectivity for model downloads
- Try different models if SmolVLM doesn't work well for your use case

## Customization

### Using Different Models
You can experiment with other vision models supported by llama.cpp:
- Modify the model name in the server command
- See [llama.cpp multimodal docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal.md) for options

### UI Modifications
Edit `index.html` to customize:
- Modern interface styling with CSS custom properties
- Dark/light theme colors and animations
- Default instructions and intervals
- Response formatting and display
- Preset API endpoints
- Keyboard shortcuts and interactions

## Contributing

Feel free to submit issues and pull requests to improve this demo!

## Business Value Proposition

### 🎯 **Transform Reactive Monitoring into Proactive Risk Prevention**

**Core Value**: Real-time AI-powered camera analysis that **prevents incidents before they happen** using high-performance vLLM inference.

**Key Benefits:**
- **⚡ Real-Time Response**: Sub-second AI analysis prevents risks from escalating
- **💰 Cost Reduction**: Automate 60-80% of routine monitoring tasks
- **🏢 Enterprise Ready**: vLLM backend delivers production-grade performance
- **📈 Scalable**: Deploy locally to enterprise (RHAIIS/OpenShift)

**Primary Use Cases:**
- **Safety Monitoring**: PPE compliance, equipment malfunctions, hazardous conditions
- **Security**: Unauthorized access, suspicious behavior, emergency detection  
- **Quality Control**: Real-time inspection and defect identification
- **Compliance**: Automated documentation and regulatory reporting

**Technical Advantage**: vLLM provides **10-20x faster inference** than standard implementations, enabling true real-time monitoring at scale.

**ROI Impact**: Prevent costly incidents, reduce security personnel needs, faster emergency response, and enhanced operational safety.

---

## License

See [LICENSE](LICENSE) file for details.
