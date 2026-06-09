# backend.tf for env: prod

# Actual backend files will be stored in remote storage a/c - secrets passed in apply workflow file

# ----------------------------------------------

terraform {

  required_version = ">=1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  /*   // passed backend values in GitHub pipeline (terraform init section)
  backend "azurerm" {
    //use_azuread_auth = true
  } */
}
