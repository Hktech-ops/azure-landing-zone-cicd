# outputs.tf for module: app-service

# ------------------------------------------------

output "app_service_plan_id" {
  description = "The ID of the App Service Plan hosting the SPA."
  value       = azurerm_service_plan.asp_spa.id
}

output "app_service_plan_name" {
  description = "The name of the App Service Plan."
  value       = azurerm_service_plan.asp_spa.name
}

output "linux_web_app_id" {
  description = "The ID of the Linux Web App (SPA)."
  value       = azurerm_linux_web_app.linux_web_app_spa.id
}

output "linux_web_app_name" {
  description = "The name of the Linux Web App (SPA)."
  value       = azurerm_linux_web_app.linux_web_app_spa.name
}

output "linux_web_app_default_hostname" {
  description = "The default hostname of the Linux Web App (SPA)."
  value       = azurerm_linux_web_app.linux_web_app_spa.default_hostname
}

output "linux_web_app_outbound_ip_addresses" {
  description = "Outbound IP addresses used by the Linux Web App."
  value       = azurerm_linux_web_app.linux_web_app_spa.outbound_ip_addresses
}

output "linux_web_app_possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses for the Linux Web App."
  value       = azurerm_linux_web_app.linux_web_app_spa.possible_outbound_ip_addresses
}

output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting applied to the Linux Web App."
  value       = azurerm_monitor_diagnostic_setting.linuz_web_app_spa_diagnostic_setting.id
}
