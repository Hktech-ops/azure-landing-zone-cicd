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
  default = "3c341c66-2169-45ff-9554-8fad1cba9202"
}

# ------------------------
# Tenant Root Group id - CLI: az account management-group list -o table & 
# CLI - az account management-group show --name --query id
# ------------------------
variable "tenant_root_group_id" {
  type    = string
  default = "/providers/Microsoft.Management/managementGroups/316cb9d3-4422-42d1-93e3-95565fee53a0"
}

