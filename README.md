# EKS Microservices Platform

The EKS Microservices Platform is a production-ready, cloud-native architecture built on Amazon EKS (Elastic Kubernetes Service) for deploying and managing containerized microservices at scale. The platform is designed with a secure networking model that leverages both Public and Private EKS API Endpoints, enabling controlled external access while ensuring worker nodes and workloads remain isolated within private subnets.

The solution incorporates AWS Load Balancer Controller for dynamic ingress management, allowing secure exposure of services through Application Load Balancers (ALBs). To provide comprehensive observability, the platform integrates Prometheus, Grafana, Alertmanager, Node Exporter, and kube-state-metrics, delivering real-time monitoring, alerting, and visualization of cluster, node, pod, and application metrics.

The architecture follows AWS best practices for security, scalability, high availability, and operational excellence, utilizing multi-AZ deployments, private worker nodes, VPC endpoints, IAM Roles for Service Accounts (IRSA), and centralized monitoring. This platform serves as a reference implementation for running enterprise-grade microservices on Kubernetes with end-to-end networking, security, and observability capabilities.

## Key Features

Amazon EKS with Public and Private API Endpoints Multi-AZ deployment for high availability Private worker nodes and workloads AWS Load Balancer Controller for ingress management Prometheus-based metrics collection Grafana dashboards and visualization Alertmanager for proactive alerting Node Exporter and kube-state-metrics integration VPC Endpoints for secure AWS service access IAM Roles for Service Accounts (IRSA) Production-grade monitoring, security, and scalability Infrastructure-as-Code ready (Terraform/CloudFormation compatible) Architecture Goals

- Security: Isolate workloads in private subnets while maintaining controlled administrative access.
- Scalability: Support horizontal scaling of microservices and worker nodes.
- Observability: Provide full-stack monitoring, alerting, and operational visibility.
- Reliability: Ensure high availability through multi-AZ deployment and resilient networking.
- Operational Excellence: Simplify deployment, monitoring, troubleshooting, and maintenance of Kubernetes workloads.

## Prerequisites

_Install_:
  - AWS CLI
  - kubectl
  - eksctl
  - Helm 3
_Verify_:

```
awsstsget-caller-identity
kubectlversion--client
helmversion
eksctlversion
```

## Architecture

[](./pub_priv_eks_pg.png)

## Step By Step Creation of Resources

### Phase 1 - Network

1. _Create VPC_

```
# CIDR:

10.0.0.0/16
```
2. _Create Public Subnets_

```
10.0.1.0/24 AZ-A
10.0.2.0/24 AZ-B

Purpose:
  - NAT Gateways
  - Public ALBs
```

3. _Create Private Subnets_

```
10.0.11.0/24 AZ-A
10.0.12.0/24 AZ-B

Purpose:
  - EKS worker nodes
  - Pods
  - Monitoring stack
```

4. _Create Internet Gateway_
Attach to VPC.

5. _Create NAT Gateways_
  - One NAT Gateway per AZ.
  - Assign Elastic IPs.


6. _Configure Route Tables_

```
Public Route Table:
0.0.0.0/0 -> Internet Gateway

Private Route Table:
0.0.0.0/0 -> NAT Gateway

```

7. _Create Security Groups_

- Cluster security group

```
Inbound:
TCP 443
Source: WorkerNodeSG

Outbound:
All
```

- Worker Node Security group

```
Outbound:
TCP 443 → Cluster SG

Inbound:
WorkerNodeSG → WorkerNodeSG
```

### Phase 2 - EKS Cluster

8. _Create EKS Cluster_

```
Enable:

endpointPublicAccess:false
endpointPrivateAccess:true

#---------------------------------------

Restrict:

publicAccessCidrs:
  -YOUR_OFFICE_IP/32
```

9. _Create Managed Node Group_

```
Place nodes only in:

PrivateSubnetA
PrivateSubnetB

#----------------------
Disable public IP assignment.

Verify:

```
kubectl get nodes
```

Expected:

STATUS Ready
```

### Phase 3 - VPC Endpoints

10. _Create Interface Endpoints_
Create:
  - ECR API
  - ECR DKR
  - STS
  - CloudWatch Logs
Create Gateway Endpoint:
  - S3
Validation:

```
kubectlruncurlpod--image=curlimages/curl-it--rm--sh
```

Inside pod:

```
curlhttps://sts.amazonaws.com
```

Expected:

```
HTTP 403

# 403 confirms connectivity
```

### Phase 4 - IAM Roles for Service Accounts

11. _Enable OIDC Provider_

```
# I use terraform

eksctlutilsassociate-iam-oidc-provider
  --clustereks-prod
  --approve

```
Verify:

```
awseksdescribe-cluster
  --nameeks-prod
  --querycluster.identity.oidc.issuer
```

### Phase 5 - AWS Load Balancer Controller

12. _Install Controller_
  - Create IAM policy.
  - Create service account.
  - Install Helm chart.

Verify:
```
kubectlgetpods-nkube-system
```

Expected:
```
aws-load-balancer-controller
Running
```

### Phase 6 - Monitoring Stack

13. _Create Monitoring Namespace_
createnamespacemonitoring

Verify:

```
kubectlgetnsmonitoring
```

14. _Add Helm Repository_

```
helmrepoaddprometheus-community
https://prometheus-community.github.io/helm-charts
helmrepoupdate
```
15. _Install kube-prometheus-stack_

```
helminstallmonitoring
prometheus-community/kube-prometheus-stack
-nmonitoring
```

This deploys:
  - Prometheus
  - Alertmanager
  - Grafana
  - Node Exporter
  - kube-state-metrics

Verify:
```
kubectlgetpods-nmonitoring
```

Expected:

```
prometheus-*
grafana-*
alertmanager-*
Running
```

### Phase 7 - Expose Grafana

16. Create Ingress

Create:

```
kind: Ingress
```
Annotations:

```
alb.ingress.kubernetes.io/scheme:internet-facing
alb.ingress.kubernetes.io/target-type:ip
```

Apply (Using terraform):

```
kubectlapply-fgrafana-ingress.yaml
```

Verify:

```
kubectlgetingress-nmonitoring
```

Expected:

```
ADDRESS:
xxxxxxxx.elb.amazonaws.com
```

### Phase 8 - GitOps Platform
- Create namespace
- Install ArgoCD

Verify

```
kubectl get pods -n argocd

# Expected

argocd-server
argocd-repo-server
argocd-application-controller
Running
```
- Install SonarQube Server

### Phase 9 - DevSecOps Platform
- Namespace: sonarqube
- Deploy 
  - SonarQube
  - PostgreSQL
  - Persistent Volume
  - Ingress

### Phase 10 - Functional Testing

- Test 1 - Public EKS Endpoint

From workstation:

```
kubectlgetnodes
```

Expected:

```
Node list returned
```

- Test 2 - Private Endpoint Usage

SSH into node or exec into pod.

Run:

```
curlhttps://<cluster-endpoint>
```

Expected:

```
403 Forbidden

# Connectivity confirmed
```

- Test 3 - Node Registration

```
kubectl get nodes -o wide
```

Expected:

```
All nodes Ready
```

- Test 4 - Prometheus Targets

portforward:

```
kubectlport-forwardsvc/monitoring-kube-prometheus-prometheus
9090:9090-nmonitoring
```

Navigate:

```
http://localhost:9090
```
Verify:

Status -> Targets

Expected:

```
All critical targets UP
```

- Test 5 - Grafana Access
Open:

```
https://grafana.company.com
```
Verify:
  - Login successful
  - Dashboards load

- Test 6 - Kubernetes Metrics

Open dashboard:

```
Kubernetes / Compute Resources / Cluster
```

Verify:
  - CPU metrics
  - Memory metrics
  - Pod metrics
  - Node metrics

- Test 7 - Alertmanager

Port forward:

```
kubectlport-forwardsvc/monitoring-kube-prometheus-alertmanager
9093:9093-nmonitoring
```

open:

```
http://localhost:9093
```
Verify:
  - Alertmanager UI loads.

- Final Validation

Confirm:

  - Public EKS Endpoint reachable from approved CIDRs
  - Worker nodes only in private subnets
  - Private Endpoint enabled
  - ECR access working
  - STS access working
  - Prometheus collecting metrics
  - Grafana displaying dashboards
  - Alertmanager operational
  - ALB exposing Grafana
  - No worker nodes have public IPs


## Resources

- [Checkov - AWS General Policies](https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/aws-general-policies)


Notes

Sonarcube
trivy
Argocd
code quality analysis
Dependency check
File scan