# Udacity AWS Cloud DevOps Engineer - Project 03 - Operationalizing a Coworking Space Microservice

## Project Overview

The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space.

This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

For this project, you are a DevOps engineer who will be collaborating with a team that is building an API for business analysts. The API provides business analysts with basic analytics data on user activity in the coworking space service. The application they provide you functions as expected, and you will help build a pipeline to deploy it to Kubernetes.

You'll submit artifacts from the build and deployment of this service.

## Getting Started
## Deployment database
### **Deploy postgresql through helm**
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgresql bitnami/postgresql --set primary.persistence.enabled=false --set postgresqlPassword=postgres
```

### **Initiate database**
- After installing helm chart to `eks` successfully. Run the bellow command instruction to initiate database schema and data
```sh
# Go to db folder
cd db

kubectl port-forward --namespace default svc/postgresql 5432:5432
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < 1_create_tables.sql
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < 2_seed_users.sql
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < 3_seed_tokens.sql
```

## Deployment Application
- build and push docker image to `AWS ECR` through `AWS CodeBuild`
- Application will be deployed to `AWS EKS`
- Every time there is a commit to `main` branch and file in `analytics` folder was changed, sourcecode will be build and deploy to `eks` </br>
please refer to [buildspec.yaml](./buildspec.yml)
</br> or you can deploy from your local pc by using the bellow command
```command
# update kubectl config: aws eks update-kubeconfig --name <<YOUR_CLUSTER>> --verbose
sh ./command/eks_config.sh super-prj3

# run deployment to eks cluster
sh ./command/eks_deploy.sh
# expose deployment
sh ./command/expose.sh
```

### CloudWatch Metrics in EKS

Kubernetes clusters created with EKS are set up to integrate with CloudWatch Container Insights by default.

This captures common sets of metrics such as CPU, memory, disk usage, and network traffic details. Additional data such as container diagnostic data is also captured.

Configuring CloudWatch Insights
CloudWatch insights are easy to configure on your cluster.

1. Node Role Policy
   Your policy for your EKS node role should include CloudWatchAgentServerPolicy for the agent to properly forward metrics.

2. Install CloudWatch Agent
   In the following command, replace `<YOUR_CLUSTER_NAME_HERE>` on line 1 with the name of your EKS cluster and replace `<YOUR_AWS_REGION_HERE>` on line 2 with your AWS region. Then, run the command on an environment that has kubectl configured.

   ```
   ClusterName=<YOUR_CLUSTER_NAME_HERE>
   RegionName=<YOUR_AWS_REGION_HERE>
   FluentBitHttpPort='2020'
   FluentBitReadFromHead='Off'
   [[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
   [[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
   curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f -
   ```

This will install CloudWatch insights into the namespace amazon-cloudwatch on your cluster.

After this is configured, you can navigate to CloudWatch in the AWS console to access CloudWatch Insights.