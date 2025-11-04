#!/bin/bash

echo "=== Setting up kubectl for Jenkins ==="

# 1. Get Kind kubeconfig
echo "Step 1: Getting Kind kubeconfig..."
kind get kubeconfig --name kind > kind-kubeconfig.yaml

# 2. Copy to Jenkins location
echo "Step 2: Copying to Jenkins directory..."
cp kind-kubeconfig.yaml /c/ProgramData/Jenkins/.jenkins/kind-kubeconfig.yaml

# 3. Verify
echo "Step 3: Verifying..."
export KUBECONFIG=/c/ProgramData/Jenkins/.jenkins/kind-kubeconfig.yaml
kubectl get nodes

echo ""
echo "✅ Setup complete!"
echo "Kubeconfig location: C:\\ProgramData\\Jenkins\\.jenkins\\kind-kubeconfig.yaml"
