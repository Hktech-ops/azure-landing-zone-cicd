# providers.tf for env --> dev

/* 
provider runtime config --> contains azurerm featues + resource-specific features

 -contains ONLY provider block
 */

# -----------------------------------------

provider "azurerm" {
  features {
  }
}
