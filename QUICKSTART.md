# Quick Start Guide

Get up and running with VLM Demo on OpenShift with GPU time-slicing in minutes.

## Prerequisites

- OpenShift 4.10+ cluster
- Node with NVIDIA GPU
- Cluster admin access
- `oc` CLI configured

## 🚀 Quick Setup (3 Steps)

### Step 1: Install GPU Operator with Time-Slicing

```bash
# Install NVIDIA GPU Operator with time-slicing enabled
oc apply -f openshift/nvidia-gpu-operator-with-timeslicing.yaml

# Wait for installation (2-5 minutes)
watch oc get csv -n nvidia-gpu-operator
# Press Ctrl+C when STATUS shows "Succeeded"

# Wait for all pods to be Running
watch oc get pods -n nvidia-gpu-operator
# Press Ctrl+C when all pods are Running
```

### Step 2: Verify GPU Time-Slicing

```bash
# Run verification script from root
./verify-gpu.sh

# Expected output: GPU capacity shows "2" ✓
```

### Step 3: Deploy VLM Workloads

**Option A: Automated Deployment (Recommended)**

```bash
# Deploy web application with automated checks
./scripts/deploy-to-openshift.sh

# The script will:
# ✓ Verify both vLLM and Llama Guard services are running
# ✓ Deploy the web application
# ✓ Create routes and services
# ✓ Provide the application URL
```

**Option B: Manual Deployment**

```bash
# Deploy Qwen2-VL (main vision-language model)
oc apply -f openshift/rhaiis-deployment.yml

# Deploy Llama-Guard (safety/guardrails)
oc apply -f openshift/llama-guard-deployment.yml

# Check deployment status
oc get pods -n rhaiis
oc get pods -n llama-guard

# Get service URLs
oc get routes -n rhaiis
oc get routes -n llama-guard
```

**🎉 Done!** Both models and the web application are now running and sharing the same GPU.

---

## 📋 Alternative: Enable Time-Slicing on Existing GPU Operator

If GPU Operator is already installed:

```bash
# Enable time-slicing
./setup-gpu-timeslicing.sh

# Verify
./verify-gpu.sh

# Deploy workloads (backend services first)
oc apply -f openshift/rhaiis-deployment.yml
oc apply -f openshift/llama-guard-deployment.yml

# Deploy web application
./scripts/deploy-to-openshift.sh
```

---

## 🔍 Verification Commands

```bash
# Check GPU capacity (should show 2)
oc get nodes -o json | jq '.items[].status.capacity["nvidia.com/gpu"]'

# Check pods using GPUs
oc get pods -n rhaiis -o wide
oc get pods -n llama-guard -o wide

# Check GPU operator pods
oc get pods -n nvidia-gpu-operator

# View model logs
oc logs -f deployment/rhaiis -n rhaiis
oc logs -f deployment/llama-guard -n llama-guard
```

---

## 📁 Project Structure

```
vlm-demo/
├── openshift/           # OpenShift deployments
│   ├── nvidia-gpu-operator-with-timeslicing.yaml
│   ├── gpu-time-slicing-config.yaml
│   ├── rhaiis-deployment.yml
│   └── llama-guard-deployment.yml
│
├── scripts/             # Automation scripts
│   ├── enable-gpu-timeslicing.sh
│   ├── verify-gpu-timeslicing.sh
│   └── ...
│
├── docs/                # Detailed documentation
│   ├── GPU-SETUP-README.md
│   ├── NVIDIA-GPU-OPERATOR-INSTALL-GUIDE.md
│   └── GPU-TIMESLICING-SETUP.md
│
├── web/                 # Web application
└── assets/              # Images/screenshots
```

---

## 🆘 Troubleshooting

### Issue: Pods in CrashLoopBackOff

```bash
# Check logs
oc logs -n nvidia-gpu-operator <pod-name> --all-containers

# Restart device plugin
oc delete pod -n nvidia-gpu-operator -l app=nvidia-device-plugin-daemonset
```

### Issue: GPU capacity still shows 1

```bash
# Reapply config
oc apply -f openshift/gpu-time-slicing-config.yaml

# Restart device plugin
oc delete pod -n nvidia-gpu-operator -l app=nvidia-device-plugin-daemonset

# Wait 1-2 minutes and verify
./verify-gpu.sh
```

### Issue: Second workload won't schedule

```bash
# Check GPU allocation
./scripts/check-current-gpu-status.sh

# Verify time-slicing is enabled
./verify-gpu.sh
```

---

## 📚 More Information

- **Detailed Setup**: See [docs/NVIDIA-GPU-OPERATOR-INSTALL-GUIDE.md](docs/NVIDIA-GPU-OPERATOR-INSTALL-GUIDE.md)
- **GPU Configuration**: See [docs/GPU-SETUP-README.md](docs/GPU-SETUP-README.md)
- **Project Structure**: See [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md)

---

## 🔗 Quick Command Reference

| Task | Command |
|------|---------|
| Install GPU Operator | `oc apply -f openshift/nvidia-gpu-operator-with-timeslicing.yaml` |
| Enable time-slicing | `./setup-gpu-timeslicing.sh` |
| Verify GPU config | `./verify-gpu.sh` |
| Deploy Qwen2-VL | `oc apply -f openshift/rhaiis-deployment.yml` |
| Deploy Llama-Guard | `oc apply -f openshift/llama-guard-deployment.yml` |
| Deploy Web App (Automated) | `./scripts/deploy-to-openshift.sh` |
| Check GPU status | `./scripts/check-current-gpu-status.sh` |
| View logs | `oc logs -f deployment/<name> -n <namespace>` |

---

## 🎯 What You Get

✅ **GPU Time-Slicing**: Share one GPU between multiple workloads  
✅ **Qwen2-VL-2B**: Vision-language model for image understanding  
✅ **Llama-Guard-3-8B**: Safety and content moderation  
✅ **Production-Ready**: Complete monitoring and validation  
✅ **Cost-Efficient**: Maximize GPU utilization  

---

**Need help?** Check the full documentation in the `docs/` directory or open an issue.
