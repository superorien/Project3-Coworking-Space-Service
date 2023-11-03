BACKEND_DEPLOYMENT_NAME="super-coworking"

# Kubectl expose
kubectl expose deployment $BACKEND_DEPLOYMENT_NAME --type=LoadBalancer --name=publicbackend