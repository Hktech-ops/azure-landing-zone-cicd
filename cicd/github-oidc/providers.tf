# providers.tf for github-oidc

provider "azurerm" {
  features {
  }
  use_oidc = true
}