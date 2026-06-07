# CAF-Aligned Azure Landing Zone with Automated Infrastructure Deployment

> Production-grade Azure Landing Zone built with Terraform and GitHub Actions, implementing Microsoft Cloud Adoption Framework (CAF) best practices — featuring centralized governance, private-first networking, Policy-as-Code, and a fully automated CI/CD pipeline with secretless authentication.

---

## Overview

This project delivers a complete Azure Landing Zone designed to demonstrate the infrastructure engineering capabilities expected of Cloud, Platform, and DevOps Engineers in enterprise environments — particularly regulated industries such as banking, insurance, and fintech.

The solution is built entirely through Infrastructure as Code and automated CI/CD, covering the full lifecycle from management group hierarchy through to application workload deployment.

**Core pillars implemented:**

- **Governance** — Management Group hierarchy, Azure Policy initiatives, mandatory tagging, region restrictions
- **Networking** — Hub-Spoke topology with Azure Firewall, Azure Bastion, forced tunneling, and Private Endpoints
- **Security** — Entra ID–only authentication, RBAC authorization, Managed Identities, private-by-default architecture
- **Observability** — Centralized Log Analytics, diagnostic settings, Entra audit/sign-in logs, AMPLS
- **Automation** — Modular Terraform with remote state, GitHub Actions CI/CD via OIDC federation
- **Data & Compute** — Azure SQL, Storage Account, Key Vault, Azure Container Registry, App Service

---

## Architecture

### High-Level Architecture

![High Level Architecture](high-level-architecture.png)

### Traffic Flow

![Traffic Flow](traffic-flow.png)

---

## Architecture Principles

### Private-by-Default

All critical PaaS services are accessible exclusively through Private Endpoints. Public network access is explicitly disabled at the resource level. This eliminates data exfiltration risk and ensures all traffic stays within the Azure backbone.

**Services secured with Private Endpoints:**

- Azure Key Vault
- Azure SQL Database
- Azure Container Registry
- Azure Storage Account (blob, file, table, queue)
- Azure Monitor (via AMPLS)

### Centralized Connectivity

Shared networking infrastructure is hosted within a dedicated Hub VNet, providing a single control point for ingress, egress, and inspection:

- Azure Firewall (Standard) — all outbound traffic inspected and controlled
- Azure Bastion — jumpbox-free administrative access
- Private Endpoint Subnet — centralized PE deployment model
- Azure Monitor Private Link Scope (AMPLS) — private ingestion of monitoring data
- Private DNS Zones — linked to both Hub and Spoke VNets for seamless resolution

Workloads are deployed in isolated Spoke VNets with no direct outbound internet access. All traffic is forced through the Hub via User Defined Routes (UDRs).

### Governance First

Resource deployment is governed at scale through:

- **Management Groups** — structured hierarchy for policy inheritance
- **Azure Policy Initiatives** — custom and built-in policies enforced at the Corp management group
- **Mandatory Tagging** — cost tracking and resource classification enforced via policy
- **Region Restrictions** — resource creation limited to approved Azure regions
- **Diagnostic Enforcement** — all supported resources automatically send logs to the central Log Analytics workspace

### Identity-Centric Security

The platform eliminates static credentials wherever possible:

- **Managed Identities** — assigned to Azure resources for service-to-service authentication
- **Entra Security Groups** — RBAC role assignments scoped to groups, not individual users
- **RBAC Authorization** — Key Vault uses Azure RBAC instead of access policies
- **Entra-only Authentication** — Azure SQL configured with `azuread_authentication_only = true`; no SQL logins
- **Entra Login for Windows** — Azure VMs joined to Entra ID for credential-free administration

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

The target subscription is placed under the Corp management group, inheriting all policy assignments and governance controls defined at the Platform and Workloads levels.


Network Architecture
Hub Network — 10.0.0.0/22

ALZ project review
Deepseek V4 Flash
Here's the full README.md — copy and paste the whole thing:

markdown
Copy
# CAF-Aligned Azure Landing Zone with Automated Infrastructure Deployment

> Production-grade Azure Landing Zone built with Terraform and GitHub Actions, implementing Microsoft Cloud Adoption Framework (CAF) best practices — featuring centralized governance, private-first networking, Policy-as-Code, and a fully automated CI/CD pipeline with secretless authentication.

---

## Overview

This project delivers a complete Azure Landing Zone designed to demonstrate the infrastructure engineering capabilities expected of Cloud, Platform, and DevOps Engineers in enterprise environments — particularly regulated industries such as banking, insurance, and fintech.

The solution is built entirely through Infrastructure as Code and automated CI/CD, covering the full lifecycle from management group hierarchy through to application workload deployment.

**Core pillars implemented:**

- **Governance** — Management Group hierarchy, Azure Policy initiatives, mandatory tagging, region restrictions
- **Networking** — Hub-Spoke topology with Azure Firewall, Azure Bastion, forced tunneling, and Private Endpoints
- **Security** — Entra ID–only authentication, RBAC authorization, Managed Identities, private-by-default architecture
- **Observability** — Centralized Log Analytics, diagnostic settings, Entra audit/sign-in logs, AMPLS
- **Automation** — Modular Terraform with remote state, GitHub Actions CI/CD via OIDC federation
- **Data & Compute** — Azure SQL, Storage Account, Key Vault, Azure Container Registry, App Service

---

## Architecture

### High-Level Architecture

![High Level Architecture](high-level-architecture.png)

### Traffic Flow

![Traffic Flow](traffic-flow.png)

---

## Architecture Principles

### Private-by-Default

All critical PaaS services are accessible exclusively through Private Endpoints. Public network access is explicitly disabled at the resource level. This eliminates data exfiltration risk and ensures all traffic stays within the Azure backbone.

**Services secured with Private Endpoints:**

- Azure Key Vault
- Azure SQL Database
- Azure Container Registry
- Azure Storage Account (blob, file, table, queue)
- Azure Monitor (via AMPLS)

### Centralized Connectivity

Shared networking infrastructure is hosted within a dedicated Hub VNet, providing a single control point for ingress, egress, and inspection:

- Azure Firewall (Standard) — all outbound traffic inspected and controlled
- Azure Bastion — jumpbox-free administrative access
- Private Endpoint Subnet — centralized PE deployment model
- Azure Monitor Private Link Scope (AMPLS) — private ingestion of monitoring data
- Private DNS Zones — linked to both Hub and Spoke VNets for seamless resolution

Workloads are deployed in isolated Spoke VNets with no direct outbound internet access. All traffic is forced through the Hub via User Defined Routes (UDRs).

### Governance First

Resource deployment is governed at scale through:

- **Management Groups** — structured hierarchy for policy inheritance
- **Azure Policy Initiatives** — custom and built-in policies enforced at the Corp management group
- **Mandatory Tagging** — cost tracking and resource classification enforced via policy
- **Region Restrictions** — resource creation limited to approved Azure regions
- **Diagnostic Enforcement** — all supported resources automatically send logs to the central Log Analytics workspace

### Identity-Centric Security

The platform eliminates static credentials wherever possible:

- **Managed Identities** — assigned to Azure resources for service-to-service authentication
- **Entra Security Groups** — RBAC role assignments scoped to groups, not individual users
- **RBAC Authorization** — Key Vault uses Azure RBAC instead of access policies
- **Entra-only Authentication** — Azure SQL configured with `azuread_authentication_only = true`; no SQL logins
- **Entra Login for Windows** — Azure VMs joined to Entra ID for credential-free administration

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
The target subscription is placed under the Corp management group, inheriting all policy assignments and governance controls defined at the Platform and Workloads levels.

Network Architecture

Hub Network — 10.0.0.0/22

Subnet	                    Purpose

AzureFirewallSubnet	        Azure Firewall (Standard)
AzureBastionSubnet	        Azure Bastion
Private Endpoint Subnet	    Centralized Private Endpoints
AMPLS Subnet	            Azure Monitor Private Link Scope
Private DNS Subnet	        Private DNS resolver integration
Reserved	                Future workload expansion


Spoke Network — 192.168.0.0/22

Subnet	                    Purpose
App Service Subnet	        App Service integration
Compute Subnet	            Virtual Machines / VMSS
Reserved	                Future workload expansion