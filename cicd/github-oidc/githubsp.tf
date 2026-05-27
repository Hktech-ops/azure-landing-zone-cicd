# main file for github service principal

/* 
Goal is to create:
 - App registration (Entra / Azure AD App)
 - Federated Credential for GitHub
 - Service principal
 - Roles/permissions to Service Principal
  - Resource level (RBAC) roles at scope 'Subscription'
  - Resource level (RBAC) + Entra ID roles at scope 'Tenant Root Group'
  - Microsoft Graph API Permissions --> these are Tenant wide permissions - via portal ONLY, Admin concent granted
    - Directory.Read.All --> to read directory data - used in module: iam
    - Group.ReadWrite.All --> to read and write all groups - used in module: iam

  - Storage Data Blob Contributor RBAC role to SP at scope 'Storage Account' --> Data Plane role for accssing Remote backend
*/

/* Roles for service principal:
Why these RBAC roles to SP?  
** 2 RBAC roles at subscription scope - Contributor, Resource Policy Contributor
** 1 Data Plane role - Storage Blob Data Contributor at scope Storage Account - for accessing remote backend
    Why? SP needs to access storage account for writing remote backend file

--> Each role covers specific capability that Terraform needs:
 - Contributor
  - Covers 95% of terraform operations such as create, update, delete, deploy resources etc...
 - Resource Policy Contributor
  - Useful for policy assignments - policies module


IMP - identity (User/SP) provisioning Mangement Group (or any operations) under Tenant Root Group needs to have these 3 roles assigned at the Tenant Root group scope

 - Management Group Contributor (RBAC role) - allows User/SP to create/modify/manage Management Groups
 - Directory Reader (Entra ID role) : allows User/SP to read tenant info
 - User Access Administrator (RBAC role) : allows assigning RBAC roles are MG, Subscription, Resources Scope

- If a user is a Global Admin - such as in my case, need to go to Entra ID > Properties and Turn ON Access management for Azure resources --> this will allow managing Tenant Root Group access controls (IAM)

*/

/* 
As the last bit in the Authorization process, I have added 
 - AZURE_CLIENT_ID
 - AZURE_SUBSCRIPTION_ID
 - AZURE_TENANT_ID
in my Github repo > secrets and variables > actions 

This completes both Azure part + GitHub part for 2 way comminication b/w Azure and Service Principal (GitHub)
*/

/* 
Directory.Read.All
Group.ReadWrite.All granted these 2 Graph API permissions to SP via portal!
 */
# --------------------------------------------

# --------------------------
# Create an App registration
# --------------------------
resource "azuread_application" "github" {
  display_name = var.azuread_app_github

  tags = ["HK", "Prod"]
}

# --------------------------------
# Service Principal for GitHub app
# --------------------------------
resource "azuread_service_principal" "github_sp" {
  client_id = azuread_application.github.client_id // client id is generated as soon as an app is registered

  tags = ["HK", "Prod"]
}

# --------------------------------
# Federated Credential for github app
# --------------------------------
resource "azuread_application_federated_identity_credential" "github-oidc" {
  application_id = azuread_application.github.id // id of the entra app provisioned earlier
  display_name   = "${var.azuread_app_github}-oidc"
  subject        = "repo:Hktech-ops/azure-landing-zone-cicd:ref:refs/heads/main"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
}

# -------------------------------------------------
# RBAC roles at scope 'Subscription'
# ------------------------------------------------
# Contributor RBAC role to sp at scope 'Subscription'
resource "azurerm_role_assignment" "contributor_to_github_sp" {
  scope                = "/subscriptions/${var.subscription_id}"
  principal_id         = azuread_service_principal.github_sp.object_id //object id of github SP
  role_definition_name = "Contributor"
}
# Resource Policy Contributor RBAC role to sp
resource "azurerm_role_assignment" "resource_policy_contributor_to_github_sp" {
  scope                = "/subscriptions/${var.subscription_id}"
  principal_id         = azuread_service_principal.github_sp.object_id //object id of github SP
  role_definition_name = "Resource Policy Contributor"
}

# -----------------------------------------------------------
# 2 RBAC roles & 1 Entra ID role to SP at scope 'Tenant Root Group'
#  - Management Group Contributor
#  - Directory Reader (Entra ID role)
#  - User Access Administrator
# Why? module: platform has to provision its mg hierarcy + assign subscription to one of the child mgs
# ------------------------------------------------------------
# --------------------------------------------
# Tenant Root Group id - CLI: az account management-group list -o table & 
# CLI - az account management-group show --name --query id
# --------------------------------------------
# Management Group Contributor (RBAC) role to SP at Tenant RG scope
resource "azurerm_role_assignment" "mg_contributor_to_github_sp" {
  scope                = var.tenant_root_group_id
  principal_id         = azuread_service_principal.github_sp.object_id //object id of github SP
  role_definition_name = "Management Group Contributor"
}

# Directory Reader (Entra ID Role) role to SP at Tenant RG scope
resource "azuread_directory_role_assignment" "directory_reader_to_github_sp" {
  role_id             = "76fd2fa4-f486-40d4-bbf0-925318e32581" //ID of Directory Readers role
  principal_object_id = azuread_service_principal.github_sp.object_id
}

# User Access Administrator (RBAC) role to SP at Tenant RG scope
resource "azurerm_role_assignment" "user_acces_admin_to_github_sp" {
  scope                = var.tenant_root_group_id
  principal_id         = azuread_service_principal.github_sp.object_id //object id of github SP
  role_definition_name = "User Access Administrator"
}


# ---------------------------------------
# Role --> at Storage A/C level
# Storage Blob Data Contributor - Data plane RBAC role for SP at scope 'storage account' - remote backend storage a/c
# ----------------------------------------
# Storage Blob Data Contributor RBAC role to sp at Storage A/C level
resource "azurerm_role_assignment" "storage_blob_data_contributor_to_github_sp" {
  // id of remote backend storage account (CLI - az storage account show --rgname --name --query id)
  scope                = "/subscriptions/1c1bf735-bff4-43f7-b6ed-9bfbb87f4840/resourceGroups/bluepeak-alz-remote-backend/providers/Microsoft.Storage/storageAccounts/bluepeakrbestorage"
  principal_id         = azuread_service_principal.github_sp.object_id //object id of github SP
  role_definition_name = "Storage Blob Data Contributor"
}


