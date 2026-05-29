# 🚀 CI/CD Pipeline Project

> Full CI/CD pipeline using **GitHub Actions**, **Ansible**, **Kubernetes**, and **Grafana**

---

## 📁 Project Structure

```
cicd-project/
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI: lint, test, docker build
│       └── cd.yml              # CD: ansible, k8s deploy, health check
├── app/
│   ├── src/index.js            # Node.js Express app
│   ├── tests/app.test.js       # Jest unit tests
│   └── package.json
├── ansible/
│   ├── playbooks/
│   │   ├── site.yml            # Main playbook
│   │   └── inventory/
│   │       ├── staging.ini
│   │       └── prod.ini
│   └── roles/
│       ├── webserver/tasks/    # UFW, packages, app user
│       └── docker/tasks/       # Docker CE + kubectl install
├── kubernetes/
│   ├── base/                   # Base manifests (deployment, service, ingress, HPA)
│   └── overlays/
│       ├── staging/            # Staging overrides (1 replica)
│       └── prod/               # Prod overrides (3 replicas, more memory)
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus.yml      # Scrape config + K8s service discovery
│   │   └── alerts.yml          # Alert rules
│   └── grafana/
│       └── dashboards/
│           └── app-dashboard.json
├── scripts/
│   ├── deploy.sh               # Manual deploy helper
│   └── rollback.sh             # One-command rollback
├── Dockerfile                  # Multi-stage build
├── docker-compose.yml          # Local dev stack
└── README.md
```

---

## ⚙️ Pipeline Flow

```
Developer push → GitHub → GitHub Actions CI
                              ├── Lint & Test (Jest)
                              ├── Security Scan (Trivy)
                              └── Docker Build & Push (GHCR)
                                        ↓
                          GitHub Actions CD
                              ├── Ansible (configure servers)
                              └── kubectl apply (Kubernetes)
                                        ↓
                          Kubernetes Cluster
                              ├── Ingress → Pods → Services
                              ├── HPA (auto-scaling)
                              └── ConfigMaps / Namespaces
                                        ↓
                          Prometheus → Grafana
                              ├── Metrics dashboards
                              └── Alerts (Slack/email)
```

---

## 🔐 Required GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description |
|--------|-------------|
| `ANSIBLE_SSH_KEY` | Private SSH key for Ansible server access |
| `ANSIBLE_HOST` | IP/hostname of your server |
| `KUBECONFIG` | Base64-encoded kubeconfig file |
| `APP_URL` | Public URL of deployed app |
| `SLACK_WEBHOOK_URL` | Slack webhook for notifications |

```bash
# Encode your kubeconfig
base64 -w 0 ~/.kube/config
```

---

## 🚀 Getting Started

### 1. Clone & set up
```bash
git clone https://github.com/YOUR_ORG/cicd-demo-app.git
cd cicd-demo-app
```

### 2. Run locally with Docker Compose
```bash
docker-compose up -d

# App:        http://localhost:3000
# Prometheus: http://localhost:9090
# Grafana:    http://localhost:3001  (admin / admin123)
```

### 3. Run tests
```bash
cd app
npm install
npm test
```

### 4. Set up Kubernetes namespaces
```bash
kubectl create namespace staging
kubectl create namespace prod

# Create image pull secret for GHCR
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_PAT_TOKEN \
  -n staging

kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_PAT_TOKEN \
  -n prod
```

### 5. Update inventory files
Edit `ansible/playbooks/inventory/staging.ini` and `prod.ini` with your server IPs.

### 6. Deploy manually (optional)
```bash
chmod +x scripts/deploy.sh scripts/rollback.sh
./scripts/deploy.sh staging sha-abc1234
```

---

## 📊 Monitoring

### Import Grafana dashboard
1. Open Grafana at `http://localhost:3001`
2. Go to **Dashboards → Import**
3. Upload `monitoring/grafana/dashboards/app-dashboard.json`

### Prometheus alerts
Alerts fire for:
- HTTP error rate > 5%
- P95 latency > 1s
- Pod crash looping
- CPU > 80%
- Memory > 85% of limit
- Deployment with 0 available replicas

---

## 🔄 Rollback

```bash
# Via script
./scripts/rollback.sh prod

# Via kubectl
kubectl rollout undo deployment/app -n prod
kubectl rollout status deployment/app -n prod
```

---

## 🧩 Tech Stack

| Tool | Purpose |
|------|---------|
| **GitHub Actions** | CI/CD orchestration |
| **Git** | Source control |
| **Docker** | Containerisation |
| **Ansible** | Server configuration |
| **Kubernetes** | Container orchestration |
| **Kustomize** | K8s manifest management |
| **Prometheus** | Metrics collection |
| **Grafana** | Dashboards & alerting |
| **Trivy** | Container security scanning |
