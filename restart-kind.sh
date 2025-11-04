#!/bin/bash

echo "=== Restarting Kind Cluster ==="

# 1. Delete broken cluster
echo "Step 1: Deleting old cluster..."
kind delete cluster --name kind

# 2. Create fresh cluster
echo "Step 2: Creating new cluster..."
kind create cluster --name kind

# 3. Wait for cluster to be ready
echo "Step 3: Waiting for cluster..."
sleep 30

# 4. Check node status
echo "Step 4: Checking node status..."
kubectl get nodes

# 5. Create dev namespace
echo "Step 5: Creating dev namespace..."
kubectl create namespace dev

# 6. Load Docker image
echo "Step 6: Loading Docker image..."
kind load docker-image kkaann/myapp:9 --name kind

# 7. Deploy application
echo "Step 7: Deploying application..."
kubectl apply -f environments/dev/deployment.yaml -n dev

# 8. Wait and check
echo "Step 8: Waiting for deployment..."
sleep 10

echo ""
echo "=== Final Status ==="
kubectl get nodes
kubectl get pods -n dev
kubectl get svc -n dev

echo ""
echo "✅ Restart complete!"
