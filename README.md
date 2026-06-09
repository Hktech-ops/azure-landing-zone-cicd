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
- **Data & Compute** — Azure SQL, Storage Account, Key Vault, Azure Container Registry & VM

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
- Azure Storage Account
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

```
Tenant Root Group
├── Platform
│   ├── Identity
│   ├── Connectivity
│   └── SharedServices
└── Workloads
    ├── Corp
    └── Online
```

The target subscription is placed under the **Corp** management group, inheriting all policy assignments and governance controls defined at the Platform and Workloads levels.

---

## Network Architecture

### Hub Network — `10.0.0.0/22`

| Subnet | Purpose |
|---|---|
| AzureFirewallSubnet | Azure Firewall |
| AzureBastionSubnet | Azure Bastion |
| Private Endpoint Subnet | Centralized Private Endpoints |
| Gateway Subnet | Azure Gateway |
| Reserved Space| Future expansion |

### Spoke Network — `192.168.0.0/22`

| Subnet | Purpose |
|---|---|
| App Service Subnet | App Service integration |
| Compute Subnet | Virtual Machine / VMSS |
| Reserved Space| Future expansion |

**Routing:** A default route (`0.0.0.0/0 → Next Hop: Azure Firewall`) is applied to all spoke subnets via UDRs, ensuring no resource can bypass the firewall for outbound traffic.

---

## Security Architecture

### Network Security

- Azure Firewall Standard with DNAT rules for controlled inbound publishing
- Network Security Groups (NSGs) on all workload subnets
- Forced tunneling through Azure Firewall — no direct outbound internet
- No public IP addresses on any workload resource
- Azure Bastion for all administrative RDP/SSH access — no public RDP/SSH ports

### Platform Security

| Control | Implementation |
|---|---|
| Key Vault | RBAC authorization, purge protection enabled |
| Azure Container Registry | Admin account disabled, private endpoint only |
| Azure SQL | Entra-only authentication, private endpoint |
| Storage Account | Public access disabled, private endpoint for all services |
| TLS Enforcement | Minimum TLS 1.2 enforced across all applicable services |

### Private Connectivity

Private DNS Zones are created and linked to both Hub and Spoke VNets for each Private Endpoint, ensuring name resolution remains internal to the virtual network fabric:

- `privatelink.vaultcore.azure.net`
- `privatelink.database.windows.net`
- `privatelink.blob.core.windows.net`
- `privatelink.azurecr.io`
- `privatelink.monitor.azure.com`
- `privatelink.oms.opinsights.azure.com` - no public ingestion of logs
- `privatelink.ods.opinsights.azure.com` - no public query of logs

---

## Monitoring & Observability

### Log Analytics Workspace

Centralized log ingestion for the entire platform:

| Log Source | Type |
|---|---|
| Azure Activity Log | Subscription-level operations |
| Azure Firewall | Network flow logs |
| Network Security Groups | NSG flow logs |
| Entra ID | Audit logs, Sign-in logs |
| Azure Resources | Diagnostic settings for all supported resource types |

### Azure Monitor Private Link Scope (AMPLS)

All monitoring traffic — log ingestion, metric collection, and querying — traverses the private network backbone via AMPLS, eliminating data exfiltration over the public internet.

### Alerting

Action Groups are configured for operational alerting, with notifications routed to the appropriate response channels - email trigger in this case.

---

## CI/CD Pipeline

Infrastructure deployment is fully automated through GitHub Actions using a two-workflow strategy that enforces quality gates before any production change.

### Workflow 1: PR Validation (`env-prod-pr-validation.yml`)

Triggered on every pull request that modifies Terraform files under `env/prod/` or `modules/`. This workflow runs **7 quality gates** before a reviewer ever sees the PR:

| Step | Tool | Purpose |
|---|---|---|
| Format Check | `terraform fmt -check` | Enforces consistent HCL formatting |
| Code Linting | TFLint | Detects provider-specific issues and anti-patterns |
| Security Scan | Checkov (soft-fail) | Scans for 700+ cloud security misconfigurations |
| Validation | `terraform validate` | Confirms syntax and internal reference correctness |
| Cost Estimation | Infracost | Estimates monthly cost of proposed changes — posted as a PR comment |
| Terraform Plan | `terraform plan` | Generates the full execution plan |
| Plan Comment | Sticky PR Comment | Posts the plan output directly on the PR for reviewer visibility |

**Why this matters:** Every change is linted, security-scanned, cost-estimated, and planned before a human reviews it. The sticky comment and Infracost comment give reviewers full context without leaving GitHub.

### Workflow 2: Production Apply (`env-prod-apply.yml`)

Triggered automatically when a pull request is merged to `main` with changes under `env/prod/` or `modules/`.

```
PR Merged → main
    ↓
Terraform Init (remote state, OIDC auth)
    ↓
Terraform Validate
    ↓
Terraform Plan
    ↓
Terraform Apply
```

**Key features:**

- **Remote State** — State stored in Azure Storage with locking for team collaboration
- **OIDC Authentication** — GitHub Actions authenticates to Azure via OpenID Connect federation; no client secrets stored in GitHub
- **Backend Injection** — Storage account details injected via GitHub Secrets at runtime, not hardcoded in the repository
- **Path Filtering** — Workflow only triggers on actual infrastructure changes, not documentation or unrelated files

### Authentication Model

```
GitHub Actions (OIDC Token)
    ↓
Azure AD (Federated Identity Credential)
    ↓
Azure Resource Manager
```

**Benefits of OIDC:**

- No long-lived client secrets stored in GitHub Secrets
- Short-lived tokens (auto-refreshed per job)
- Federated identity credential eliminates service principal password rotation
- Industry best practice for CI/CD security in enterprise environments

---

## Terraform Architecture

### Module Structure

```
env/
└── prod/
    ├── main.tf          # Root module — orchestrates all child modules
    ├── backend.tf        # Remote state configuration
    ├── providers.tf      # Provider configuration with OIDC
    ├── variables.tf      # Environment-specific variables
    └── prod.tfvars       # Production variable values

modules/
├── platform              # Management groups, policy assignments, RBAC
├── monitoring            # Log Analytics workspace, diagnostics, AMPLS
├── hub-network           # Hub VNet, firewall, bastion, private DNS
├── spoke-network         # Spoke VNet, subnets, peering, UDRs
├── firewall-policies     # Firewall policy rules, DNAT, network/application rules
├── policies              # Custom policy definitions, initiatives, assignments
├── iam                   # Entra security groups, role assignments
├── paas-resources        # Key Vault, SQL, Storage, ACR, App Service
└── compute               # Virtual machines, VMSS
```

### Design Decisions

| Decision | Rationale |
|---|---|
| **Separate modules per concern** | Enables independent testing, reuse across environments, and clear dependency chains |
| **Remote state with locking** | Prevents concurrent state corruption in team workflows |
| **Backend config injected at runtime** | Keeps storage credentials out of version control |
| **`-var-file` per environment** | Clean separation of environment-specific values from module logic |
| **No hardcoded resource names in modules** | All names passed as variables — modules remain reusable |

---

## Key Engineering Decisions

| Decision | Rationale |
|---|---|
| Hub-Spoke Architecture | Industry-standard network segmentation; scales to multiple workloads |
| Azure Firewall | Centralized policy enforcement for egress traffic |
| Private Endpoints | Eliminates public exposure of PaaS services; meets compliance requirements |
| OIDC Federation | Secretless authentication for CI/CD; no credential rotation overhead |
| Managed Identities | Removes static credentials from application configuration |
| Azure Policy | Enforces governance at scale without manual intervention |
| RBAC Authorization | Modern, group-based access control for Azure resources |
| Centralized Logging | Single pane of glass for security and operational events |
| Checkov + TFLint in CI/CD | Catches misconfigurations before they reach Azure |
| Infracost in PRs | Embeds FinOps awareness into the development workflow |

---

## Skills Demonstrated

### Azure Platform

Azure Landing Zones, Management Groups, Azure Policy, Azure Firewall, Azure Bastion, Azure Monitor, Private Link, App Service, Azure SQL, Key Vault, Azure Container Registry, Log Analytics, Entra ID, RBAC, Managed Identities, Private DNS, Virtual Network Peering, Network Security Groups, Route Tables

### Infrastructure as Code

Terraform (HCL), Modular Architecture, Remote State Management, State Locking, Dependency Management, Variable Separation, Terraform Registry

### DevOps & CI/CD

GitHub Actions, OIDC Federation, Workflow Orchestration, Quality Gates (TFLint, Checkov, Infracost), Sticky PR Comments, Secret Management, Backend Injection, Path-Based Triggers

### Security & Compliance

Zero Trust Principles, Least Privilege Access, Private Connectivity, Identity-Based Authentication, Policy-as-Code, Compliance Scanning, Cost Governance (FinOps)

---

## Future Enhancements

- **Application Gateway WAF** — Layer 7 ingress with web application firewall
- **Microsoft Defender for Cloud** — Advanced threat protection and regulatory compliance scoring
- **AKS Workload Deployment** — Containerized workloads with private cluster integration
- **Blue/Green Deployment Strategy** — Zero-downtime infrastructure updates

---

## Deployment

```bash
# Navigate to the target environment
cd env/prod

# Initialize with remote state backend
terraform init

# Review the execution plan
terraform plan -var-file="prod.tfvars"

# Apply the infrastructure
terraform apply -var-file="prod.tfvars"
```

Terraform state is stored remotely in Azure Storage with state locking enabled, supporting team collaboration and preventing concurrent execution conflicts.

---

## Author

**Harsh Kathwadia** — Cloud / Platform / DevOps Engineer
