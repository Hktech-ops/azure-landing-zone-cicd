# main.tf for module: firewall


/* It deploys:
 - Firewall (Platform firewall)
  - firewall private IP : outputted
 
 - Diagnostic setting for Firewall - logs sent to central LAW 
*/
# -------------------------------------------

# Tags
locals {
  common_tags = {
    author = "HK"
    env = "Prod"
  }
}


# ===============================
# Firewall - private IP, deployment & diagnostic setting
# Firewall policy - in a separate module: firewall-policies
# ===============================
# Platform Firewall deployment
resource "azurerm_firewall" "platform_firewall" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.platform_firewall_name
  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  ip_configuration {
    name = "${var.platform_firewall_name}-ipconfig"
    subnet_id = var.firewall_subnet_id  // referenced from module: hub-network
    public_ip_address_id = var.platform_firewall_public_ip_id // referenced from module: hub-network

    //Azure will assign private (static) IP for firewall
  }

  firewall_policy_id = var.platform_firewall_policy_id   //from module: firewall-policies

  tags = local.common_tags
}

# Diagnostic setting for Firewall
resource "azurerm_monitor_diagnostic_setting" "platform_firewall_diagnostic_setting" {
  name = var.platform_firewall_diagnostic_setting
  target_resource_id = azurerm_firewall.platform_firewall.id
  log_analytics_workspace_id = var.law_id   // sent to cental LAW, LAW id - referenced from module: monitoring

  enabled_log {
    category = "AzureFirewallApplicationRule"  // for FQDN filtering logs
  }
  enabled_log {
    category = "AzureFirewallNetworkRule"  // for IP/port filtering logs
  }
  enabled_log {
    category = "AzureFirewallDnsProxy"  // for DNS queries
  }
}