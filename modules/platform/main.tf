#  main.tf for module: platform

# associated subscription to 'workloads-corp' Management group

/* Management Groups structure:
Tenant Root Group
│
├── Platform (Parent MG) 
│   ├── Identity
│   ├── Connectivity
│   └── SharedServices
│
└── Workloads (Parent MG)
    ├── Corp -----> associated subscription to this MG
    └── Online 
*/

/* 
provioned a Resource Group - one for this project

deployed a centralized Recovery Services Vault (PaaS resource) - for backups and site recovery workloads
 - used in this project, primarily for storing VM backups
 - generally, Recovery services vault is used for sotring VM backups, Azure Files backups, SQL server on VM backups, AKS backups and so on..

*/

/* 
IMP - identity (user/SP) provisioning Mangement Group (or any operations) under Tenant Root Group needs to have these 3 roles assigned at the Tenant Root group scope
** Owner --> highly privileged and supercedes all these roles!

 - Management Group Contributor - allows User/SP to create/modify/manage Management Groups
 - Directory Reader - allows User/SP to read tenant info
 - User Access Administrator : allows assigning RBAC roles are MG, Subscription, Resources Scope

- If a user is a Global Admin - such as in my case, need to go to Entra ID > Properties and Turn ON Access management for Azure resources --> this will take care for the user!
 - Why? This is ARM plane permisison, which is different than Control Place or Data Plane
 - Remember, ARM Plane roles are highly privileged roles - typically used to manage Management groups

*/

/* 
tenant_root_group_id --> CLI = az accout management-goup list
subscription_id --> CLI = az account show --query id --> /subscriptions/"**<id>** 
tenant id --> CLI = az account show
*/

# -----------------------------------------------

# data source - azurerm_subscription retrieves details about the subscription Terraform is authenticated against
data "azurerm_subscription" "azure_subscription" {
}

# -----------------------------------------------
# parent - platform mg (child of tenant root group)
# child - identity, connectivity, sharedservices mg
# --------------------------------------------------
resource "azurerm_management_group" "platform_parent_mg" {
  display_name               = var.platform_mg_name
  parent_management_group_id = var.tenant_root_group_id //this mg is going to be the child of tenant root group!
}
resource "azurerm_management_group" "identity_child_mg" {
  display_name               = var.platform_identity_mg_name
  parent_management_group_id = azurerm_management_group.platform_parent_mg.id
}
resource "azurerm_management_group" "connectivity_child_mg" {
  display_name               = var.platform_connectivity_mg_name
  parent_management_group_id = azurerm_management_group.platform_parent_mg.id
}
resource "azurerm_management_group" "sharedservices_child_mg" {
  display_name               = var.platform_sharedservices_mg_name
  parent_management_group_id = azurerm_management_group.platform_parent_mg.id
}

# -----------------------------------------------
# parent - workloads mg (child of tenant root group)
# child - corp & online mg
# associated existing subscription to corp child mg
# -----------------------------------------------
resource "azurerm_management_group" "workloads_parent_mg" {
  display_name               = var.workloads_mg_name
  parent_management_group_id = var.tenant_root_group_id //this mg is going to be the child of tenant root group!
}
resource "azurerm_management_group" "corp_child_mg" {
  display_name               = var.workloads_corp_mg_name
  parent_management_group_id = azurerm_management_group.workloads_parent_mg.id
}
resource "azurerm_management_group" "online_child_mg" {
  display_name               = var.workloads_online_mg_name
  parent_management_group_id = azurerm_management_group.workloads_parent_mg.id
}
# associated existing subscription to corp child mg
resource "azurerm_management_group_subscription_association" "sub_to_corp_mg" {
  management_group_id = azurerm_management_group.corp_child_mg.id
  subscription_id     = var.subscription_id
}

# --------------------
# Resource Group
# --------------------
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location

  tags = {
    author = "HK"
    env    = "Prod"
  }
}

# -------------------------
# Recovery Services Vault
# -------------------------
resource "azurerm_recovery_services_vault" "cnsolns_recovery_services_vault" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = var.cnsolns_recovery_services_vault_name
  sku                 = "Standard"

  soft_delete_enabled = false // disabled for now
  //soft_delete_enabled = true  --> wanted to save credits!

  tags = {
    author = "HK"
    env    = "Prod"
  }
}
