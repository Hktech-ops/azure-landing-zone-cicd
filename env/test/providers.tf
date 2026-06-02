# providers.tf for env --> test

/* 
provider runtime config --> contains azurerm featues + resource-specific features

 -contains ONLY provider block + Key Vault features
 */

# -----------------------------------------

provider "azurerm" {
  features {
  }
}
