# main.tf for module: firewall policies

/* 
firewall policy
firewall policy rules collection groups : 3
 
 - dnat rules collection group
  - inbound from internet on 80 & 443, translated to VM's private IP
   - Why? I have deployed SPA on VM

 - network rules collection group
  - allowed ALL outbound from VM 

 - application rules collection group
  - allowed all FQDNs from VM

 */
# ---------------------------------------------

# tags
locals {
  common_tags = {
    author = "HK"
    env    = "Prod"
  }
}

# ==============================
# Firewall policy
# ==============================
# Firewall policy
resource "azurerm_firewall_policy" "platform_firewall_policy" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.platform_firewall_policy_name

  sku = "Standard"

  threat_intelligence_mode = "Alert"
  //threat_intelligence_mode = "AlertAndDeny"

  tags = local.common_tags
}

# ============================================================
# DNAT RULES (INBOUND)
# ============================================================
resource "azurerm_firewall_policy_rule_collection_group" "dnat_rules_cg" {
  name               = var.dnat_rules_cg_name
  firewall_policy_id = azurerm_firewall_policy.platform_firewall_policy.id
  priority           = 100

  nat_rule_collection {
    name     = "inbound-web"
    priority = 100
    action   = "Dnat"

    rule {
      name              = "http-to-appvm"
      protocols         = ["TCP"]
      source_addresses  = ["*"]
      destination_ports = ["80"]
      # traffic from internet hits firewall's public ip first
      destination_address = var.platform_firewall_public_ip_address // referenced from module: hub-network
      translated_address = "192.168.0.4" // inbound to vm's private IP: referenced from module: compute
      translated_port    = "80"
    }

    rule {
      name                = "https-to-appvm"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_ports   = ["443"]
      # traffic from internet hits firewall's public ip first
      destination_address = var.platform_firewall_public_ip_address // referenced from module: hub-network
      translated_address  = "192.168.0.4" // inbound to vm's private IP: referenced from module: compute
      translated_port     = "443"
    }
  }
}


# ============================================================
# NETWORK RULES (OUTBOUND)
# ============================================================
resource "azurerm_firewall_policy_rule_collection_group" "network_rules_cg" {
  name               = var.network_rules_cg_name
  firewall_policy_id = azurerm_firewall_policy.platform_firewall_policy.id
  priority           = 200

  network_rule_collection {
    name     = "allow-all-network"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-all-outbound"
      protocols             = ["Any"]
      //referenced from module: spoke-network & keyed in tfvars
      source_addresses      = var.app_subnet_cidr //allowed outbound from app subnet - vm lies inside app subnet
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}


# ============================================================
# APPLICATION RULES (OUTBOUND)
# ============================================================
resource "azurerm_firewall_policy_rule_collection_group" "app_rules_cg" {
  name               = var.app_rules_cg_name
  firewall_policy_id = azurerm_firewall_policy.platform_firewall_policy.id
  priority           = 300

  application_rule_collection {
    name     = "allow-web-outbound"
    priority = 100
    action   = "Allow"

    rule {
      name             = "allow-http-https"
      //referenced from module: spoke-network & keyed in tfvars
      source_addresses = var.app_subnet_cidr   // allowed outbound form app subnet - vm lies inside app subnet

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }

      destination_fqdns = ["*"]
    }
  }
}

