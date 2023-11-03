## Apply env variables and secrets
kubectl apply -f ./deployments/env-secret.yaml
kubectl apply -f ./deployments/env-configmap.yaml

## Deployments
kubectl apply -f ./deployments/app-deployment.yaml

## Service
kubectl apply -f ./deployments/app-service.yaml
