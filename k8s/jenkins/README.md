# Jenkins Deployment Guide

To deploy Jenkins inside your Kubernetes cluster, we use the official Jenkins Helm Chart.

## Prerequisites
- Helm v3 installed locally (`brew install helm` or `choco install kubernetes-helm`)
- `kubectl` configured to communicate with your Kops cluster.

## Deployment Steps

1. Add the Jenkins Helm repository:
   ```bash
   helm repo add jenkins https://charts.jenkins.io
   helm repo update
   ```

2. Create a namespace for Jenkins:
   ```bash
   kubectl create namespace jenkins
   ```

3. Install Jenkins using the provided `values.yaml` file:
   ```bash
   helm install my-jenkins jenkins/jenkins -n jenkins -f values.yaml
   ```

4. Retrieve the Jenkins admin password:
   By default, the `values.yaml` sets the password to `admin_password`. If you remove that from `values.yaml` for security, retrieve it via:
   ```bash
   kubectl exec --namespace jenkins -it svc/my-jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
   ```

5. Access Jenkins:
   Port-forward the Jenkins service to access it locally:
   ```bash
   kubectl --namespace jenkins port-forward svc/my-jenkins 8080:8080
   ```
   Open `http://localhost:8080` in your browser.

## Configuration
Once logged in, configure your credentials (`dockerhub-credentials` for Docker, `kops-kubeconfig` for Kubernetes) and create a Pipeline job pointing to your Git repository's `Jenkinsfile`.
