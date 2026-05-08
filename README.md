# Cloud-Native TaskApp Deployment

Welcome to the Cloud-Native TaskApp Infrastructure repository. This project demonstrates a production-ready application environment using modern DevOps practices, including Infrastructure as Code, CI/CD, Containerization, and AWS Cloud Deployment.

## Architecture Overview

The system is deployed on a highly available, multi-AZ Kubernetes cluster orchestrated on AWS EC2 instances (via Kops). 

- **Cloud Provider**: Amazon Web Services (AWS)
- **Infrastructure as Code (IaC)**: Terraform manages the foundational AWS resources (VPC, IAM, DNS).
- **Cluster Management**: Kops provisions the Kubernetes control plane and worker nodes across 3 Availability Zones (`us-east-1a`, `us-east-1b`, `us-east-1c`).
- **Containerization**: The backend (Python/Flask) and frontend (React) are fully containerized using Docker.
- **CI/CD Pipeline**: Jenkins and GitHub Actions automate the Build, Test, and Deploy phases.
- **Monitoring & Logging**: AWS CloudWatch Agent and Fluent Bit capture container metrics and logs for centralized observability.
- **Ingress & TLS**: NGINX Ingress Controller paired with Cert-Manager provides secure HTTPS endpoints.

## Deployment Steps

Follow these steps to deploy the complete infrastructure and application:

### 1. Provision Infrastructure (Terraform)
Launch the foundational network, IAM roles, and DNS configuration:
```bash
./scripts/setup_remote_state.sh
cd terraform
terraform init
terraform apply -auto-approve
```

### 2. Build Kubernetes Cluster (Kops)
Use Kops to deploy the Kubernetes cluster into the VPC created by Terraform:
```bash
./scripts/deploy_kops.sh
kops replace -f kops/cluster.yaml
kops update cluster --name taskapp.fantoforever.com --yes --admin
kops validate cluster --wait 10m
```

### 3. CI/CD Setup (Jenkins / GitHub Actions)
**Option A: Jenkins (Preferred)**
1. Deploy Jenkins to the cluster using the Helm instructions in `k8s/jenkins/README.md`.
2. Configure your DockerHub (`dockerhub-credentials`) and Kubeconfig (`kops-kubeconfig`) credentials in Jenkins.
3. Create a Multibranch Pipeline pointing to this repository to automatically run the `Jenkinsfile`.

**Option B: GitHub Actions**
1. Add `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `KOPS_STATE_STORE` to your repository secrets.
2. The `.github/workflows/deploy.yml` will automatically build, test, and deploy upon pushing to the `main` branch.

### 4. Deploy Monitoring
The pipelines will automatically apply the manifests, but you can manually deploy AWS CloudWatch monitoring:
```bash
kubectl apply -f k8s/monitoring/
```

### 5. Application Deployment
The CI/CD pipeline deploys the workloads. To manually apply the application manifests:
```bash
./scripts/deploy_k8s_apps.sh
```

## Design Decisions

- **Terraform + Kops**: We chose Terraform for predictable, declarative infrastructure foundation (VPCs, IAM), and Kops for native Kubernetes lifecycle management on AWS EC2. This provides the flexibility of EC2 with the robustness of a managed cluster.
- **Jenkins inside Kubernetes**: Jenkins is deployed via Helm directly into the cluster to leverage Kubernetes as dynamic build agents, providing scalable and isolated CI/CD executions.
- **Fluent Bit + CloudWatch**: Fluent Bit is lightweight and highly performant compared to Fluentd or Logstash, making it the ideal daemon for shipping Kubernetes logs to AWS CloudWatch.
- **Multi-AZ Deployment**: The control plane and worker nodes span 3 Availability Zones to guarantee fault tolerance and high availability.

## Assumptions Made

- You possess an active AWS account with programmatic Administrator access.
- A registered domain (e.g., `taskapp.fantoforever.com`) is available in Route53 for DNS resolution and TLS certificate generation.
- A DockerHub account is available for hosting the container registry.
- Terraform remote state is successfully initialized via the provided setup script.

## Any Limitations or Improvements

- **Limitations**:
  - The current setup uses `t3.small` instances to remain within cost-effective limits, which may struggle under high concurrent loads.
  - Basic testing is implemented in the CI/CD pipeline; comprehensive integration testing should be added.
- **Future Improvements**:
  - Migrate to AWS EKS for a fully managed control plane, reducing the operational overhead of Kops.
  - Implement Horizontal Pod Autoscaling (HPA) and Cluster Autoscaler to dynamically adjust to traffic spikes.
  - Introduce Prometheus and Grafana for more granular, dashboard-driven metrics beyond basic CloudWatch logs.
