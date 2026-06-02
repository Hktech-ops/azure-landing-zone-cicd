# outputs.tf for github oidc

# App's client id
output "app_client_id" {
  value = azuread_application.github.client_id
}

# App's object id
output "app_object_id" {
  value = azuread_application.github.object_id
}

# SP's object id
output "sp_object_id" {
  value = azuread_service_principal.github_sp.object_id
}