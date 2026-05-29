# outputs.tf for module: firewall policies

# ------------------------------------------

# Firewall public IP outputs
output "platform_firewall_public_ip_id" {
  description = "ID of the Firewall Public IP"
  value       = azurerm_public_ip.platform_firewall_public_ip.id
}
output "platform_firewall_public_ip_address" {
  description = "Firewall's public IP address"
  value = azurerm_public_ip.platform_firewall_public_ip.ip_address
}

# Firewall policy outputs
output "platform_firewall_policy_id" {
  description = "The ID of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.platform_firewall_policy.id
}

output "platform_firewall_policy_name" {
  description = "The name of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.platform_firewall_policy.name
}

output "dnat_rule_collection_group_id" {
  description = "The ID of the DNAT rule collection group."
  value       = azurerm_firewall_policy_rule_collection_group.dnat_rules_cg.id
}

output "network_rule_collection_group_id" {
  description = "The ID of the Network rule collection group."
  value       = azurerm_firewall_policy_rule_collection_group.network_rules_cg.id
}

output "application_rule_collection_group_id" {
  description = "The ID of the Application rule collection group."
  value       = azurerm_firewall_policy_rule_collection_group.app_rules_cg.id
}


