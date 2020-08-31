# AWS Infrastructure for application running on ECS
### This project contains the Terraform files to provision the infrastructure to host this app https://github.com/balefr1/fileshare-app on AWS public cloud

![Alt text](fileshare-app-infrastructure.jpg?raw=true "Title")

This Terraform project pretty much creates the infrastructure described in the picture above.
It features:
- VPC, subnets, gateways (internet and NAT)
- R53 public hosted zone
- ACM certificate
- Application Load Balancer
- ECS cluster with task definition
- CodeDeploy Application&DeploymentGroup for blue/green releases with ECS
- EFS volume and mountpoints
- ECR repository 
- Bastion Host
- RDS MySQL database
