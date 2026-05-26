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
