# common providers.tf for all environments

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_key_vaults = true
    }
  }

  use_oidc = true # without this, terraform will authenticate using CLI (by default), but we want it by OIDC
}