# variables.tf for github oidc

# ------------------------
# Enterprise app nmae
# ------------------------
variable "azuread_app_github" {
  type    = string
  default = "github"
}

# ------------------------
# Subscription id - CLI: az account show --query id
# ------------------------
variable "subscription_id" {
  type    = string
  default = "1c1bf735-bff4-43f7-b6ed-9bfbb87f4840"
}

# ------------------------
# Tenant Root Group id - CLI: az account management-group list -o table & 
# CLI - az account management-group show --name --query id
# ------------------------
variable "tenant_root_group_id" {
  type    = string
  default = "/providers/Microsoft.Management/managementGroups/2b4bb9a8-b0c8-415d-a87c-919dd639e8f5"
}
