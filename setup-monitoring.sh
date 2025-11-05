#!/bin/bash

function slack_notify() {
  local message=$1
  if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "Slack webhook URL is not set, skipping notification."
    return
  fi
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${message}\"}" $SLACK_WEBHOOK_URL
}

echo "═══════════════════════════════════════════════════════"
echo "     Setting up Monitoring Stack (Prometheus + Grafana)"
echo "═══════════════════════════════════════════════════════"
echo ""

slack_notify "🔧 Starting setup of Monitoring Stack (Prometheus + Grafana)"

# Create monitoring namespace
echo "Step 1: Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
slack_notify "✅ Monitoring namespace created"

# Install Prometheus
echo ""
echo "Step 2: Installing Prometheus..."
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml

sleep 10
slack_notify "✅ Prometheus installed"

echo ""
echo "Step 3: Creating Prometheus instance..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
      - job_name: 'kubernetes-apiservers'
        kubernetes_sd_configs:
        - role: endpoints
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https

      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
        - role: node
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)

      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: \$1:\$2
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name

      - job_name: 'kubernetes-services'
        kubernetes_sd_configs:
        - role: service
        metrics_path: /metrics
        relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: replace
          target_label: __scheme__
          regex: (https?)
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
          action: replace
          target_label: __address__
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: \$1:\$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      serviceAccountName: prometheus
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
          - '--web.console.libraries=/usr/share/prometheus/console_libraries'
          - '--web.console.templates=/usr/share/prometheus/consoles'
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus
        - name: prometheus-storage
          mountPath: /prometheus
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
      - name: prometheus-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - port: 9090
    targetPort: 9090
    nodePort: 30090
  selector:
    app: prometheus
EOF

echo ""
echo "Step 4: Installing Grafana..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: admin
        - name: GF_INSTALL_PLUGINS
          value: grafana-piechart-panel
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
      volumes:
      - name: grafana-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 30030
  selector:
    app: grafana
EOF

echo ""
echo "Step 5: Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=120s deployment/grafana -n monitoring

slack_notify "✅ Monitoring Stack Installed Successfully! Prometheus at http://localhost:30090, Grafana at http://localhost:30030"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅ Monitoring Stack Installed Successfully!"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📊 Access URLs:"
echo "   Prometheus: http://localhost:30090"
echo "   Grafana:    http://localhost:30030"
echo ""
echo "🔑 Grafana Credentials:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "📝 Next Steps:"
echo "   1. Port-forward to access locally:"
echo "      kubectl port-forward -n monitoring svc/prometheus 9090:9090"
echo "      kubectl port-forward -n monitoring svc/grafana 3000:3000"
echo ""
echo "   2. Add Prometheus as data source in Grafana:"
echo "      URL: http://prometheus.monitoring.svc:9090"
echo ""
echo "   3. Import Kubernetes dashboards (IDs):"
echo "      - 8588 (Kubernetes Cluster)"
echo "      - 6417 (Kubernetes Deployment)"
echo "      - 315 (Kubernetes Pod)"
echo ""
echo "═══════════════════════════════════════════════════════"

# Check status
echo ""
echo "Current Status:"
kubectl get all -n monitoring
