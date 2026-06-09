#  CAF-Aligned Azure Landing Zone with automated Infrastructure Deployment

> Production-oriented Azure Landing Zone built with Terraform and GitHub Actions, implementing Microsoft Cloud Adoption Framework (CAF) principles, centralized governance, private-first networking, and automated Infrastructure as Code deployment.

----

## Overview

This project demonstrates the design and deployment of a modern Azure Landing Zone using Terraform and GitHub Actions.

The solution follows core Microsoft Cloud Adoption Framework (CAF) recommendations and incorporates:

* Management Group hierarchy
* Hub-Spoke networking
* Azure Firewall and Bastion
* Azure Policy governance
* Centralized monitoring and diagnostics
* Private Endpoints and Private DNS
* Entra ID based access control
* GitHub Actions CI/CD using OpenID Connect (OIDC)
* Infrastructure deployment automation

The objective is to showcase the responsibilities typically owned by Cloud Engineers, Platform Engineers, and DevOps Engineers in enterprise Azure environments.

---

## Key Capabilities

| Domain                 | Implementation                                                              |
| ---------------------- | --------------------------------------------------------------------------- |
| Governance             | Management Groups, Policy Initiatives, Tag Enforcement, Region Restrictions |
| Networking             | Hub-Spoke Architecture, Azure Firewall, Bastion, UDRs, NSGs                 |
| Security               | Private Endpoints, Private DNS, Entra RBAC, Managed Identities              |
| Identity               | Entra Security Groups, Least Privilege Access, Entra-only Authentication    |
| Observability          | Log Analytics, Diagnostic Settings, Activity Logs, Entra Logs, AMPLS        |
| Infrastructure as Code | Modular Terraform Architecture                                              |
| CI/CD                  | GitHub Actions with OIDC Federation                                         |
| Data Services          | Azure SQL, Storage Account, Key Vault, Azure Container Registry             |
| Operations             | Centralized Monitoring, Alerting, Backup Policies                           |

---

## Architecture

### High-Level Architecture

![High Level Architecture](high-level-architecture.png)

### Traffic Flow

![Traffic Flow](traffic-flow.png)

---

## Architecture Principles

The platform was designed around several core principles commonly used in enterprise Azure environments:

### Private-by-Default

All critical PaaS services are exposed through Private Endpoints. Public access is disabled.

Services include:

* Azure Key Vault
* Azure SQL Database
* Azure Container Registry
* Azure Storage Account
* Azure Monitor

### Centralized Connectivity

Shared networking services are hosted within the Hub VNet:

* Azure Firewall
* Azure Bastion
* Private Endpoint Subnet
* Azure Monitor Private Link Scope (AMPLS)

Workloads are deployed within isolated Spoke VNets.

### Governance First

Resource deployment is governed through:

* Management Groups
* Azure Policy Initiatives
* Mandatory Tagging
* Region Restrictions
* Diagnostic Enforcement Policies

### Identity-Centric Security

The platform avoids credential-based administration where possible through:

* Managed Identities
* Entra Security Groups
* RBAC Authorization
* Entra Authentication for SQL
* Entra Login for Windows

---

## Landing Zone Topology

### Management Group Hierarchy

```text
Tenant Root Group
├── Platform
│   ├── Identity
│   ├── Connectivity
│   └── SharedServices
└── Workloads
    ├── Corp
    └── Online
```

The subscription is associated to the Corp Management Group and inherits governance controls through policy assignments.

---

## Network Architecture

### Hub Network

```text
10.0.0.0/22
```

Contains:

* Azure Firewall
* Azure Bastion
* Private Endpoint Subnet
* Azure Monitor Private Link Scope
* Private DNS Services

### Spoke Network

```text
192.168.0.0/22
```

Contains:

* Application Workloads
* App Service Integration
* Compute Resources
* Future Platform Expansion

All outbound traffic is routed through Azure Firewall using User Defined Routes.

---

## Security Architecture

### Network Security

* Azure Firewall Standard
* DNAT for controlled inbound publishing
* NSGs on all workload subnets
* Forced tunneling through Firewall
* No public IPs on workload resources
* Azure Bastion for administrative access

### Platform Security

* Key Vault RBAC authorization
* ACR admin account disabled
* SQL Entra-only authentication
* Purge Protection enabled
* Storage public access disabled
* TLS 1.2 enforced

### Private Connectivity

Private Endpoints are deployed for:

* Azure Key Vault
* Azure SQL
* Azure Storage
* Azure Container Registry
* Azure Monitor

Private DNS Zones are linked to both Hub and Spoke VNets to ensure private resolution across the platform.

---

## Monitoring & Observability

Centralized observability is implemented through:

### Log Analytics Workspace

Collects:

* Azure Activity Logs
* Azure Firewall Logs
* NSG Logs
* Entra Audit Logs
* Entra Sign-In Logs
* Resource Diagnostic Logs

### Azure Monitor Private Link Scope (AMPLS)

Monitoring traffic remains on private network paths and does not traverse public endpoints.

### Alerting

Action Groups provide centralized notification for operational events and monitoring alerts.

---

## CI/CD Pipeline

Infrastructure deployment is automated through GitHub Actions.

### Infrastructure Deployment

Terraform workflow performs:

```text
Validate
    ↓
Plan
    ↓
Apply
```

Features:

* Remote Terraform State
* State Locking
* OIDC Authentication
* Environment Variable Injection
* Automated Infrastructure Deployment

### Authentication Model

GitHub Actions authenticates to Azure using OpenID Connect (OIDC).

Benefits:

* No client secrets stored in GitHub
* Short-lived federated tokens
* Reduced credential management overhead
* Enterprise security best practice

---

## Terraform Architecture

```text
envs/
└── prod/

modules/
├── platform
├── monitoring
├── hub-network
├── spoke-network
├── firewall-policies
├── policies
├── iam
├── paas-resources
├── compute
```

The solution follows a modular architecture that separates platform concerns into reusable Terraform modules.

---

## Application Workload

The landing zone hosts a sample application deployed through App Service.

The application demonstrates:

* CI/CD driven deployment
* Secure platform consumption
* Managed Identity integration
* Private-first architecture patterns

---

## Key Engineering Decisions

| Decision               | Rationale                                  |
| ---------------------- | ------------------------------------------ |
| Hub-Spoke Architecture | Scalable network segmentation model        |
| Azure Firewall         | Centralized ingress and egress control     |
| Private Endpoints      | Eliminate public exposure of PaaS services |
| OIDC Federation        | Secretless GitHub authentication           |
| Managed Identities     | Reduce credential management               |
| Azure Policy           | Governance at scale                        |
| RBAC Authorization     | Modern Azure access control model          |
| Centralized Logging    | Unified operational visibility             |

---

## Skills Demonstrated

### Azure

* Azure Landing Zones
* Management Groups
* Azure Policy
* Azure Firewall
* Azure Bastion
* Azure Monitor
* Private Link
* App Service
* Azure SQL
* Key Vault
* Azure Container Registry

### Infrastructure as Code

* Terraform
* Modular Architecture
* Remote State Management
* Dependency Management

### DevOps

* GitHub Actions
* OIDC Federation
* CI/CD Automation
* Infrastructure Deployment Pipelines

### Security

* Zero Trust Principles
* Least Privilege Access
* Private Connectivity
* Identity-Based Authentication

---

## Future Enhancements

Potential next steps include:

* Application Gateway WAF
* Azure Defender for Cloud
* Microsoft Sentinel
* Multi-environment promotion pipelines
* AKS workload deployment
* Blue/Green deployment strategy

---

## Deployment

```bash
cd envs/prod

terraform init

terraform plan -var-file="terraform.tfvars"

terraform apply -var-file="terraform.tfvars"
```

Terraform state is stored remotely in Azure Storage to support collaboration, consistency, and state locking.

---

## Author

Harsh Kathwadia
