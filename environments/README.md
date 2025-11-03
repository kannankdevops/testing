\# Multi-Environment Deployment Configurations



This directory contains environment-specific Kubernetes deployment configurations following GitOps best practices.



\## 📁 Directory Structure

```

environments/

├── dev/

│   └── deployment.yaml      # Development environment

├── test/

│   └── deployment.yaml      # Testing environment

├── prod/

│   └── deployment.yaml      # Production environment

└── README.md                # This file

```



\## 🎯 Environment Differences



\### Dev Environment

\- \*\*Replicas\*\*: 1

\- \*\*Resources\*\*: Minimal (64Mi-256Mi RAM, 50m-250m CPU)

\- \*\*Image\*\*: `latest` tag (auto-updates)

\- \*\*Log Level\*\*: `debug`

\- \*\*Purpose\*\*: Active development and debugging



\### Test Environment

\- \*\*Replicas\*\*: 2

\- \*\*Resources\*\*: Medium (128Mi-512Mi RAM, 100m-500m CPU)

\- \*\*Image\*\*: `latest` tag

\- \*\*Log Level\*\*: `info`

\- \*\*Purpose\*\*: Integration testing and QA



\### Prod Environment

\- \*\*Replicas\*\*: 3 (with HPA 3-10)

\- \*\*Resources\*\*: High (256Mi-1Gi RAM, 200m-1000m CPU)

\- \*\*Image\*\*: Specific version tag (e.g., `v1.0.0`)

\- \*\*Log Level\*\*: `warn`

\- \*\*Features\*\*: 

&nbsp; - Horizontal Pod Autoscaler

&nbsp; - Rolling updates (maxUnavailable: 0)

&nbsp; - Stricter health checks

\- \*\*Purpose\*\*: Production workloads



\## 🚀 Deployment Commands



\### Deploy to Dev

```bash

kubectl create namespace dev

kubectl apply -f environments/dev/deployment.yaml

```



\### Deploy to Test

```bash

kubectl create namespace test

kubectl apply -f environments/test/deployment.yaml

```



\### Deploy to Prod

```bash

kubectl create namespace prod

kubectl apply -f environments/prod/deployment.yaml

```



\## 🔄 Update Strategy



\### Dev/Test

\- Use `latest` tag

\- Automatic updates when new images are pushed

\- Fast iteration



\### Prod

\- Use specific version tags (v1.0.0, v1.1.0, etc.)

\- Manual version updates via PR

\- Controlled releases



\## 📊 Resource Scaling



| Environment | Min Replicas | Max Replicas | CPU Request | Memory Request |

|-------------|--------------|--------------|-------------|----------------|

| Dev         | 1            | 1            | 50m         | 64Mi           |

| Test        | 2            | 2            | 100m        | 128Mi          |

| Prod        | 3            | 10 (HPA)     | 200m        | 256Mi          |



\## ✅ Verification



\### Check Deployment Status

```bash

kubectl get deployments -n dev

kubectl get deployments -n test

kubectl get deployments -n prod

```



\### Check Pods

```bash

kubectl get pods -n dev

kubectl get pods -n test

kubectl get pods -n prod

```



\### Check Services

```bash

kubectl get services -n dev

kubectl get services -n test

kubectl get services -n prod

```



\### Check HPA (Prod Only)

```bash

kubectl get hpa -n prod

kubectl describe hpa myapp-hpa -n prod

```



\## 🎯 GitOps Best Practices



1\. ✅ \*\*Declarative\*\*: All configs in Git

2\. ✅ \*\*Versioned\*\*: Git history tracks all changes

3\. ✅ \*\*Immutable\*\*: Prod uses specific versions

4\. ✅ \*\*Pull-based\*\*: Changes pulled from Git

5\. ✅ \*\*Environment Parity\*\*: Similar structure across environments



\## 🔒 Security Notes



\- Never commit secrets to Git

\- Use Kubernetes Secrets or external secret management

\- Prod namespace should have strict RBAC policies

\- Use network policies to isolate environments



\## 📝 Next Steps



1\. Create CI/CD pipeline to automate deployments

2\. Add monitoring and alerting

3\. Implement blue-green or canary deployments

4\. Add network policies for environment isolation

