# Production-Grade 3-Tier AWS Infrastructure with Modular Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-5.0%2B-FF9900?logo=amazon-aws&logoColor=white)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![Architecture](https://img.shields.io/badge/Design-3--Tier_Modular-blue)](#architecture-overview)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An enterprise-ready, modular, and highly available 3-Tier cloud infrastructure provisioned on AWS using HashiCorp Terraform. This architecture separates concerns across Presentation (ALB), Logic/Compute (Auto Scaling EC2), and Data Storage (Encrypted Amazon RDS PostgreSQL) across multi-AZ configurations while strictly adhering to the **Principle of Least Privilege** and Infrastructure as Code (IaC) best practices.

---

## Architecture Overview

```text
                                      INTERNET
                                         │
                                         ▼
                            ┌────────────────────────┐
                            │ Internet Gateway (IGW) │
                            └───────────┬────────────┘
                                        │
┌─ VPC (10.0.0.0/16) ───────────────────┼────────────────────────────────────────┐
│                                       │                                        │
│   PUBLIC TIER                         ▼                                        │
│   ┌────────────────────────────────────────────────────────────────────────┐   │
│   │  Public Subnet A (ap-south-1a)         Public Subnet B (ap-south-1b)   │   │
│   │  ┌─────────────────────────┐           ┌─────────────────────────┐     │   │
│   │  │    NAT Gateway (EIP)    │           │                         │     │   │
│   │  └────────────┬────────────┘           └─────────────────────────┘     │   │
│   │               │                                                        │   │
│   │               ▼                                                        │   │
│   │  ┌──────────────────────────────────────────────────────────────────┐  │   │
│   │  │           Application Load Balancer (ALB) - Public Ingress       │  │   │
│   │  └────────────────────────────────┬─────────────────────────────────┘  │   │
│   └───────────────────────────────────┼────────────────────────────────────┘   │
│                                       │ Target Group Routing                   │
│   PRIVATE APPLICATION TIER            ▼                                        │
│   ┌────────────────────────────────────────────────────────────────────────┐   │
│   │  Private App Subnet A                  Private App Subnet B            │   │
│   │  ┌─────────────────────────┐           ┌─────────────────────────┐     │   │
│   │  │   EC2 Instance (Auto)   │           │   EC2 Instance (Auto)   │     │   │
│   │  │    [Managed by ASG]     │           │    [Managed by ASG]     │     │   │
│   │  └────────────┬────────────┘           └────────────┬────────────┘     │   │
│   └───────────────┼─────────────────────────────────────┼──────────────────┘   │
│                   │                                     │                      │
│   PRIVATE DATABASE TIER (Fully Isolated)                │                      │
│   ┌───────────────┼─────────────────────────────────────┼──────────────────┐   │
│   │               └──────────────────┬──────────────────┘                  │   │
│   │                                  ▼                                     │   │
│   │  Private DB Subnet A                   Private DB Subnet B             │   │
│   │  ┌───────────────────────────────────────────────────────────────┐     │   │
│   │  │             Amazon RDS Multi-AZ PostgreSQL Engine             │     │   │
│   │  │                  (Encrypted, Private Subnet)                  │     │   │
│   │  └───────────────────────────────────────────────────────────────┘     │   │
│   └────────────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## Key Highlights & Enterprise Features

* **Strict 3-Tier Separation:**
  * **Public Tier:** Hosts the internet-facing Application Load Balancer and NAT Gateway across 2 Availability Zones.
  * **Private App Tier:** Stateless compute layer hosting EC2 instances managed by an Auto Scaling Group (ASG). No public IPs are assigned to EC2. Outbound connectivity (patching/updates) is strictly routed through the NAT Gateway.
  * **Private DB Tier:** Dedicated database subnet group hosting Amazon RDS PostgreSQL. Completely isolated with no outbound or inbound internet routing.
* **Security Group Chaining (Zero-Trust Model):**
  * ALB accepts port `80` traffic from `0.0.0.0/0`.
  * App EC2 instances strictly accept traffic referencing the **ALB Security Group ID** as the source.
  * RDS PostgreSQL strictly accepts traffic referencing the **App Security Group ID** on port `5432`.
* **High Availability & Self-Healing:**
  * Multi-AZ distribution (`ap-south-1a`, `ap-south-1b`).
  * Auto Scaling automatically replaces unhealthy instances based on ALB target group health checks.
* **Remote State Management & State Locking:**
  * Centralized state stored in Amazon S3 with server-side encryption (SSE).
  * Distributed state locking powered by Amazon DynamoDB to prevent concurrent executions and race conditions.
* **Modular & DRY Architecture:**
  * Reusable modules for `vpc`, `security`, `compute`, and `database`.
  * Environment orchestration cleanly isolated in `environments/prod`.

---

## Repository Structure

```text
.
├── modules/
│   ├── vpc/                    # Reusable VPC, Subnets, IGW, NAT Gateway, Route Tables
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/               # ALB, App, and RDS Security Groups with strict chaining
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/                # ALB, Target Groups, Launch Template & Auto Scaling Group
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── database/               # RDS PostgreSQL instance & DB Subnet Group
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   └── prod/                   # Production environment deployment
│       ├── backend.tf          # S3 Backend + DynamoDB State Locking configuration
│       ├── main.tf             # Module orchestration & AWS provider setup
│       ├── variables.tf        # Environment input variable declarations
│       ├── terraform.tfvars    # Environment-specific configuration values
│       └── outputs.tf          # Root outputs (ALB DNS name, DB endpoint)
└── README.md
```

---

## Security Group Reference

| Tier | Resource | Ingress Rule | Egress Rule |
| :--- | :--- | :--- | :--- |
| **Tier 1 (Public)** | Application Load Balancer | `TCP 80` from `0.0.0.0/0` | `TCP 80` to App Instances |
| **Tier 2 (Private App)** | EC2 Instances (ASG) | `TCP 80` strictly from `ALB Security Group ID` | Outbound to internet via NAT Gateway (`-1`) |
| **Tier 3 (Private DB)** | RDS PostgreSQL | `TCP 5432` strictly from `App Security Group ID` | Explicitly restricted (`egress = []`) |

---

## Deployment Guide

### Prerequisites

* [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and configured with programmatic IAM access.
* [Terraform v1.5+](https://developer.hashicorp.com/terraform/install) installed.

### 1. Remote Backend Bootstrap

Before deploying the environment, create the S3 bucket and DynamoDB table used for remote state storage:

```bash
# Create S3 bucket for remote state
aws s3api create-bucket \
  --bucket <your-unique-tf-state-bucket-name> \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning on state bucket
aws s3api put-bucket-versioning \
  --bucket <your-unique-tf-state-bucket-name> \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

> **Note:** Update `environments/prod/backend.tf` with your specific S3 bucket name before proceeding.

### 2. Provision Infrastructure

```bash
# Navigate to the production environment
cd environments/prod

# Initialize Terraform (downloads AWS provider, sets up S3 backend, loads modules)
terraform init

# Validate configuration syntax
terraform validate

# Review planned changes
terraform plan

# Apply infrastructure changes
terraform apply
```

After provisioning completes, Terraform displays the outputs:
```text
Outputs:
alb_public_url = "http://prod-alb-xxxxxxxxx.ap-south-1.elb.amazonaws.com"
database_endpoint = "prod-db.xxxxxxxxx.ap-south-1.rds.amazonaws.com:5432"
```

### 3. Verify Deployment

1. Copy the `alb_public_url` from the outputs and open it in a web browser.
2. Refresh multiple times to verify traffic distribution across healthy EC2 instances in different Availability Zones.

---

## Teardown & Cost Management

To avoid ongoing AWS charges (particularly for the NAT Gateway and RDS instance) when not in use:

```bash
cd environments/prod
terraform destroy -auto-approve
```

---

## Author

* **Sahil Sutar** — Cloud & DevOps Enthusiast
* GitHub: [@sahil-sutar](https://github.com/sahil-sutar)
* Focus Areas: Infrastructure as Code (IaC), AWS Architecture, Automated CI/CD, Containerization
