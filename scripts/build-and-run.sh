#!/usr/bin/env bash
set -e
# Build Docker images
echo "Building Docker images..."
docker-compose -f ../docker/docker-compose.yml build
# Run docker-compose for local testing
echo "Starting containers via Docker Compose..."
docker-compose -f ../docker/docker-compose.yml up -d
# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f ../k8s/namespace.yaml
kubectl apply -f ../k8s/
# Stream logs and setup port-forward
kubectl -n poc get pods
echo "Forwarding service ports for local testing..."
kubectl -n poc port-forward svc/app-service 8080:80 &
# Tail logs
kubectl -n poc logs -f deployment/app-deploymentZA
