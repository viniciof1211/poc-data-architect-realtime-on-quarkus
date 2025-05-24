# Install Chocolatey if not installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
# Install Minikube or MicroShift
choco install minikube -y
minikube start --driver=hyperv

# Install oc CLI for OpenShift
choco install openshift-cli -y
oc login https://localhost:6443 --token=$env:OPENSHIFT_TOKEN

# Create namespace and apply manifests
oc new-project poc
oc apply -f k8s/namespace.yaml
oc apply -f k8s/quarkus-deployment.yaml
oc apply -f k8s/service.yaml
oc apply -f k8s/ingress.yaml