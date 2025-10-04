# Project Structure

This document describes the organization of the vlm-demo repository.

## Directory Layout

```
vlm-demo/
├── README.md                      # Main project documentation
├── LICENSE                        # Project license
├── PROJECT-STRUCTURE.md          # This file - project organization guide
│
├── openshift/                     # OpenShift deployment files
│   ├── rhaiis-deployment.yml                      # Qwen2-VL-2B deployment (main VLM)
│   ├── llama-guard-deployment.yml                 # Llama-Guard-3-8B deployment (safety)
│   ├── nvidia-gpu-operator-with-timeslicing.yaml  # GPU Operator + time-slicing setup
│   └── gpu-time-slicing-config.yaml               # Time-slicing ConfigMap only
│
├── scripts/                       # Automation scripts
│   ├── enable-gpu-timeslicing.sh      # Enable time-slicing on existing setup
│   ├── verify-gpu-timeslicing.sh      # Verify time-slicing configuration
│   ├── check-current-gpu-status.sh    # Check GPU allocation status
│   ├── build-and-push.sh              # Build and push demo containers
│   └── build-and-push-prod.sh         # Build and push production containers
│
├── docs/                          # Documentation
│   ├── GPU-SETUP-README.md                    # Overview of GPU setup files
│   ├── NVIDIA-GPU-OPERATOR-INSTALL-GUIDE.md   # Complete GPU Operator installation guide
│   └── GPU-TIMESLICING-SETUP.md               # Time-slicing configuration guide
│
├── web/                           # Web application files
│   ├── index.html                 # Development web interface
│   ├── prod-index.html            # Production web interface
│   ├── prod-guardrail-index.html  # Production interface with guardrails
│   └── Containerfile.web          # Container build file for web app
│
└── assets/                        # Static assets (images, etc.)
    ├── demo.png                   # Demo screenshot
    └── vllm.png                   # vLLM logo/diagram
```

## Directory Descriptions

### `/` (Root)
- **README.md**: Main project documentation and getting started guide
- **LICENSE**: Project license information
- **PROJECT-STRUCTURE.md**: This file - describes the repository organization

### `openshift/`
Contains all OpenShift manifests for deploying the VLM demo and infrastructure.

**Deployment Files:**
- `rhaiis-deployment.yml`: Deploys Qwen2-VL-2B-Instruct vision-language model using Red Hat AI Inference Server (RHAIIS)
- `llama-guard-deployment.yml`: Deploys Llama-Guard-3-8B for content safety and guardrails

**GPU Configuration:**
- `nvidia-gpu-operator-with-timeslicing.yaml`: All-in-one file to install NVIDIA GPU Operator with time-slicing enabled (for fresh installations)
- `gpu-time-slicing-config.yaml`: ConfigMap to enable GPU time-slicing on existing GPU Operator installations

### `scripts/`
Automation scripts for building, deploying, and managing the infrastructure.

**GPU Management:**
- `enable-gpu-timeslicing.sh`: Automated script to enable GPU time-slicing on an existing GPU Operator
- `verify-gpu-timeslicing.sh`: Verify that GPU time-slicing is correctly configured
- `check-current-gpu-status.sh`: Check current GPU capacity and pod allocation

**Container Build:**
- `build-and-push.sh`: Build and push demo application containers
- `build-and-push-prod.sh`: Build and push production application containers

**Usage:**
```bash
# Run scripts from the scripts/ directory
cd scripts/
./enable-gpu-timeslicing.sh
./verify-gpu-timeslicing.sh

# Or from root with relative paths
./scripts/enable-gpu-timeslicing.sh
```

### `docs/`
Comprehensive documentation for setup, configuration, and troubleshooting.

- **GPU-SETUP-README.md**: Quick reference guide for all GPU-related files and workflows
- **NVIDIA-GPU-OPERATOR-INSTALL-GUIDE.md**: Step-by-step installation guide with troubleshooting
- **GPU-TIMESLICING-SETUP.md**: Detailed guide for enabling GPU time-slicing

**When to Use:**
- New to the project? Start with `GPU-SETUP-README.md`
- Fresh installation? Read `NVIDIA-GPU-OPERATOR-INSTALL-GUIDE.md`
- Existing setup? Follow `GPU-TIMESLICING-SETUP.md`

### `web/`
Web application files and containerization.

- **index.html**: Development/demo web interface for VLM interaction
- **prod-index.html**: Production web interface
- **prod-guardrail-index.html**: Production interface with Llama-Guard integration
- **Containerfile.web**: Container build file for packaging the web application

### `assets/`
Static assets such as images, diagrams, and screenshots.

- **demo.png**: Screenshot of the application in action
- **vllm.png**: vLLM architecture or logo

## Common Workflows

### 1. Fresh GPU Operator Installation

```bash
# Apply all-in-one GPU Operator with time-slicing
oc apply -f openshift/nvidia-gpu-operator-with-timeslicing.yaml

# Wait for installation to complete
watch oc get csv -n nvidia-gpu-operator

# Verify time-slicing
./scripts/verify-gpu-timeslicing.sh
```

### 2. Enable Time-Slicing on Existing GPU Operator

```bash
# Run the automation script
./scripts/enable-gpu-timeslicing.sh

# Verify configuration
./scripts/verify-gpu-timeslicing.sh
```

### 3. Deploy VLM Workloads

```bash
# Deploy main VLM model
oc apply -f openshift/rhaiis-deployment.yml

# Deploy safety/guardrail model
oc apply -f openshift/llama-guard-deployment.yml

# Check status
oc get pods -n rhaiis
oc get pods -n llama-guard
```

### 4. Build and Deploy Web Application

```bash
# Build containers
cd scripts/
./build-and-push-prod.sh

# Deploy web app
oc apply -f openshift/<your-web-deployment>.yaml
```

## File Naming Conventions

- **OpenShift manifests**: `*.yml` or `*.yaml`
- **Shell scripts**: `*.sh`
- **Documentation**: `*.md` in docs/, or descriptive names in root (e.g., `PROJECT-STRUCTURE.md`)
- **Web files**: `*.html` in web/
- **Assets**: Descriptive names in assets/

## Path References

When referencing files from scripts:

- **From root**: Use relative paths like `openshift/rhaiis-deployment.yml`
- **From scripts/**: Use `../openshift/rhaiis-deployment.yml`
- **From openshift/**: Use `../scripts/verify-gpu-timeslicing.sh`

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        OpenShift Cluster                         │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              NVIDIA GPU Operator (nvidia-gpu-operator)      │ │
│  │  • GPU Drivers          • Device Plugin (time-slicing)      │ │
│  │  • Container Toolkit    • DCGM Monitoring                   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌──────────────────────┐       ┌──────────────────────┐        │
│  │  rhaiis namespace    │       │ llama-guard namespace│        │
│  │                      │       │                      │        │
│  │  Qwen2-VL-2B        │       │  Llama-Guard-3-8B   │        │
│  │  (Vision-Language)  │       │  (Safety/Guardrails)│        │
│  │  GPU: 1 (shared)    │       │  GPU: 1 (shared)    │        │
│  └──────────────────────┘       └──────────────────────┘        │
│           ▲                               ▲                      │
│           │                               │                      │
│  ┌────────┴───────────────────────────────┴────────────────┐    │
│  │              Web Application (smolvlm-demo)             │    │
│  │  • User Interface       • API Integration               │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## Contributing

When adding new files:

1. **OpenShift manifests** → `openshift/`
2. **Scripts** → `scripts/` (make executable: `chmod +x`)
3. **Documentation** → `docs/`
4. **Web files** → `web/`
5. **Images/assets** → `assets/`

Update this document (`PROJECT-STRUCTURE.md`) when adding new directories or significant files.

## Support

For questions about:
- **GPU setup**: See `docs/GPU-SETUP-README.md`
- **Installation**: See `docs/NVIDIA-GPU-OPERATOR-INSTALL-GUIDE.md`
- **Time-slicing**: See `docs/GPU-TIMESLICING-SETUP.md`
- **Project structure**: This file

## Quick Links

- [Main README](README.md)
- [GPU Setup Guide](docs/GPU-SETUP-README.md)
- [Installation Guide](docs/NVIDIA-GPU-OPERATOR-INSTALL-GUIDE.md)
- [Time-Slicing Setup](docs/GPU-TIMESLICING-SETUP.md)
