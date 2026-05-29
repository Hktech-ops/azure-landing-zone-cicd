# main.tf for module: iam - identity and access management
# there are two files in this module - main and outputs.tf

/* 
This module provides centralized user management for Entra ID users
Specifically, it controls definining users (data sources), creating groups and adding members to groups
*/

/* Goal:
 - import users (data sources) that are already present in Entra ID
 - **** assign Entra ID roles (privileged) roles to select users
 - create groups - Sql admins, KV Admins, ACR managers, Storage A/C Contributor, Virtual Machine Administrator
 - add members to groups
*/

/* 
About Entra ID (directory) roles :
 - User Mike Mason: Default Microsoft Account, has Global Admin Entra role
 - User Harsh: Assigned User + Groups Administrator Entra Roles 
*/

# -----------------------------------------------------------------

# Define users - already present in Entra ID. Remember, you need to add users to entra id first
data "azuread_user" "mike_mason" {
  user_principal_name = "miketechnical70_gmail.com#EXT#@miketechnical70gmail.onmicrosoft.com"
}
data "azuread_user" "harsh" {
  user_principal_name = "harsh@miketechnical70gmail.onmicrosoft.com"
}


# ------------------------------------
# Create a group - SQL admins group
# Added user to this group
# ------------------------------------
resource "azuread_group" "sql_admins_group" {
  display_name     = "sql-admins"
  security_enabled = true
}
# Add users to sql_admin group
resource "azuread_group_member" "sql_admins_group_members" {
  group_object_id  = azuread_group.sql_admins_group.object_id
  member_object_id = data.azuread_user.harsh.object_id //object id of the user
}

# ---------------------------
# Group - Key Vault Admins
# Added user to this group
# ---------------------------
resource "azuread_group" "key_vault_admins_group" {
  display_name     = "key-vaults-admins"
  security_enabled = true
}
# Add users to Key Vault Admins group
resource "azuread_group_member" "key_vault_admins_group_members" {
  group_object_id  = azuread_group.key_vault_admins_group.object_id
  member_object_id = data.azuread_user.harsh.object_id  //object id of the user
}

# -------------------------------
# Group - ACR Managers
# Added user to this group
# -------------------------------
resource "azuread_group" "acr_managers_group" {
  display_name     = "acr-managers"
  security_enabled = true
}
# Add users to ACR Managers group
resource "azuread_group_member" "acr_managers_group_members" {
  group_object_id  = azuread_group.acr_managers_group.object_id
  member_object_id = data.azuread_user.harsh.object_id    //object id of the user
}

# -------------------------------
# Group - Storage account contributors
# Added user to this group
# -------------------------------
resource "azuread_group" "storage_ac_contributors" {
  display_name     = "storage-ac-contributors"
  security_enabled = true
}
# Add users to Storage account contributors group
resource "azuread_group_member" "storage_ac_contributors_group_members" {
  group_object_id  = azuread_group.storage_ac_contributors.object_id
  member_object_id = data.azuread_user.harsh.object_id    //object id of the user
}

# -------------------------------
# Group - VM admins : If you happen to deploy VM in the environment!
# Added user to this group
# -------------------------------
resource "azuread_group" "vm_admins_group" {
  display_name     = "vm-admins"
  security_enabled = true
}
# Add users to VM admins group
resource "azuread_group_member" "vm_admins_group_members" {
  group_object_id  = azuread_group.vm_admins_group.object_id
  member_object_id = data.azuread_user.harsh.object_id    //object id of the user
}
