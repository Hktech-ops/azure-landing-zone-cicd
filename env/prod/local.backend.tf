# local backend config --> used for local backend duing pr-validation

/* 
Conceptually, PR valiadation should never touch remote (actual) backend

This file overrides your azurerm backend ONLY during PR validation.

Terraform backend precedence:

    - If you pass a backend config → it overrides backend.tf
    - If you dont → backend.tf is used 

**** Recall, pr-validation -->  uses terraform init -backend=false
*/

# ---------------------------------------------------

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
