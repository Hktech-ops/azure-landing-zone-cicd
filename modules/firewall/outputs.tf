# outputs.tf for module: firewall


# ============================
# Firewall
# ============================
output "platform_firewall_public_ip_id" {
  description = "ID of the Firewall Public IP"
  value       = azurerm_public_ip.platform_firewall_public_ip.id
}
output "platform_firewall_public_ip_address" {
  description = "Firewall's public IP address"
  value = azurerm_public_ip.platform_firewall_public_ip.ip_address
}
output "platform_firewall_id" {
  description = "ID of the Azure Firewall"
  value       = azurerm_firewall.platform_firewall.id
}
output "platform_firewall_private_ip_address" {
  description = "Private IP of the Azure Firewall"
  value       = azurerm_firewall.platform_firewall.ip_configuration[0].private_ip_address
}

# ============================
# Firewall Diagnostic Settings
# ============================

output "platform_firewall_diagnostic_setting_id" {
  description = "ID of the Firewall Diagnostic Setting"
  value       = azurerm_monitor_diagnostic_setting.platform_firewall_diagnostic_setting.id
}