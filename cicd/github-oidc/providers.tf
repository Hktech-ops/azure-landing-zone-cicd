# providers.tf for github-oidc

provider "azurerm" {
  features {
  }
  use_oidc = true // without this OIDC authentication will fail (refer pipeline manifest)
}