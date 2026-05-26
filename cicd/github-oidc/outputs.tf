# outputs.tf for github oidc

# Enterprise App's client id
output "client_id" {
  value = azuread_application.github.client_id
}

# Enterprise App's object id
output "object_id" {
  value = azuread_application.github.object_id
}

