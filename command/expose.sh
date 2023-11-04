BACKEND_DEPLOYMENT_NAME="super-coworking"

# Kubectl expose
kubectl expose deployment super-coworking --type=LoadBalancer --name=publicbackend