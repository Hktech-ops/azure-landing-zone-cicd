# main file for github service principal

/* 
Goal is to create:
 - App registration (Entra / Azure AD App)
 - Federated Credential for GitHub
 - Service principal
 - Roles/permissions to Service Principal
*/

/* Roles for service principal:
Why these 4 RBAC roles to SP? 3 
** 3 Control Plane roles at subscription level - Contributor, Resource Policy Contributor, User Access Administrator
** 1 Data Plane role - Storage Blob Data Contributor at scope Storage Account - for accessing remote backend
    Why? SP needs to access storage account for writing remote backend file

--> Each role covers specific capability that Terraform needs:
 - Contributor
  - Covers 95% of terraform operations such as create, update, delete, deploy resources etc...
 - Resource Policy Contributor
  - Useful for policy assignments - policies module
 - User Access Administrator
  - assign/remove roles to identities


IMP - identity (User/SP) provisioning Mangement Group (or any operations) under Tenant Root Group needs to have these 3 roles assigned at the Tenant Root group scope

 - Management Group Contributor - allows User/SP to create/modify/manage Management Groups
 - Directory Reader - allows User/SP to read tenant info
 - User Access Administrator : allows assigning RBAC roles are MG, Subscription, Resources Scope

- If a user is a Global Admin - such as in my case, need to go to Entra ID > Properties and Turn ON Access management for Azure resources --> this will take care for the user!
 - Why? This is ARM plane permisison, which is different than Control Place or Data Plane
 - Remember, ARM Plane role are highly privileged roles - typically used to manage Management groups

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
Group.Read.Write.All granted these 2 Graph API permissions to SP!!!
 */ 
# --------------------------------------------

# --------------------------
# Create an App registration
# --------------------------
resource "azuread_application" "github" {
  display_name = var.azuread_app_github

  tags = [ "HK", "Prod" ]
}

# --------------------------------
# Service Principal for GitHub app
# --------------------------------
resource "azuread_service_principal" "github_sp" {
  client_id = azuread_application.github.client_id // client id is generated as soon as an app is registered

  tags = [ "HK", "Prod" ]
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
# User Access Administrator RBAC role to sp
resource "azurerm_role_assignment" "user_acces_admin_to_github_sp" {
  scope                = "/subscriptions/${var.subscription_id}"
  principal_id         = azuread_service_principal.github_sp.object_id //object id of github SP
  role_definition_name = "User Access Administrator"
}

# ------------------------------
# RBAC roles for SP at Storage A/C // + Container scope
# ------------------------------
# Storage Blob Data Contributor RBAC role to sp at Storage A/C level
resource "azurerm_role_assignment" "storage_blob_data_contributor_to_github_sp" {
  // id of remote backend storage account (CLI - az storage account show --rgname --name --query id)
  scope                = "/subscriptions/1c1bf735-bff4-43f7-b6ed-9bfbb87f4840/resourceGroups/bluepeak-alz-remote-backend/providers/Microsoft.Storage/storageAccounts/bluepeakrbestorage"
  principal_id         = azuread_service_principal.github_sp.object_id //object id of github SP
  role_definition_name = "Storage Blob Data Contributor"
}


