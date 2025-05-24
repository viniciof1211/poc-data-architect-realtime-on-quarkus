# Install Chocolatey if not installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
# Install kubectl and minikube
choco install kubernetes-cli -y
choco install minikube -y
# Configure Minikube to use Docker
minikube config set driver docker
# Start Minikube cluster with addons
minikube start --memory=4096 --cpus=2
minikube addons enable dashboard
minikube addons enable metrics-server
Write-Host 'Kubernetes cluster is up and running on Minikube.'