// main.tf for module: hub-network

/* 
hub vnet = 10.0.0.0/22  --> total 1024 ips
  - firewall subnet = 10.0.0.0/26  --> 64 ips
  - bastion subnet = 10.0.0.64/26  --> 64 ips
  - gateway subnet = 10.0.0.128/27 --> 32 ips
  - private endpoints subnet = 10.0.1.0/24  --> 256 ips
    - contains PE for "azuremonitor"
    - contains PE for PaaS resources - Key Vault, ACR, Storage, SQL DB
*** private endpoints subnet - NO RT, NO UDRs, NO NSG, NO Firewall, NO subnet delegation, dedicated ONLY to PEs
    - recall, role of a private endpoints is to provide a NIC in the Vnet/subnet for other resources to communicate

  
  - 10.0.2.0/24 - 256 ips available for future expansion
  - 10.0.3.0/24 - 256 ips available for future expansion 



Platform firewall public ip - just the public ip provisioned here
 - it will be used in other modules: firewall and firewall-policies


Bastion Host + bastion's public IP - for secure admin access

AMPLS - for centralized monitoring
Private endpoint for "azuremonitor", connected with AMPLS in shared services subnet
Private DNS zones for monitor, oms (for ingestion) and ods (for query)
  - Goal: log ingestion + query of logs ONLY from private network --> NO public access to logs
*/

#-----------------------------------------------------------------

# Tags
locals {
  common_tags = {
    author = "HK"
    env = "Prod"
  }
}

# =======================
# hub vnet & its subnets
# Keyed vaules in tfvars
# =======================
resource "azurerm_virtual_network" "hub_vnet" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.hub_vnet_name
  address_space = var.hub_vnet_address_space  // keyed value in tfvars
  
  #address_space = [ "10.0.0.0/22" ]   // 1024 ips

  tags = local.common_tags
}
# firewall subnet
resource "azurerm_subnet" "firewall_subnet" {
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  name = var.firewall_subnet_name
  address_prefixes = var.firewall_subnet_cidr // keyed value in tfvars

  # address_prefixes = [ "10.0.0.0/26" ]    // 64 ips
}
# bastion subnet
resource "azurerm_subnet" "bastion_subnet" {
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  name = var.bastion_subnet_name
  address_prefixes = var.bastion_subnet_cidr  // keyed value in tfvars

  # address_prefixes = [ "10.0.0.64/26" ]  // 64 ips
}
# gateway subnet
resource "azurerm_subnet" "gateway_subnet" {
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  name = var.gateway_subnet_name
  address_prefixes = var.gateway_subnet_cidr  // keyed value in tfvars

  # address_prefixes = [ "10.0.0.128/27" ]   // 32 ips
}

# private endpoints subnet
resource "azurerm_subnet" "private_endpoints_subnet" {
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  name = var.private_endpoints_subnet_name
  address_prefixes = var.private_endpoints_subnet_cidr // keyed value in tfvars

  # address_prefixes = [ "10.0.1.0/24" ]  // 256 ips

  private_endpoint_network_policies_enabled = false  // this turns OFF network policies like UDR, NSGs - which is required for private endpoints to work!
  # No UDR, NSG etc. on private endpoints subnet allowed!
}

# -----------------------------------
# Hub Vnet - furute expansion room (intentionally left over)
# -----------------------------------
// 10.0.2.0/24 - 256 IPs, free for future expansion
// 10.0.3.0/24 - 256 IPs, free for future expansion
// total - 512 IPs free for future expansion


# =====================================================
# Public IP for Platform Firewall - just the public ip provisioned here in this module
# this public ip will be used by modules: firewall and firewall-policies
# =====================================================
resource "azurerm_public_ip" "platform_firewall_public_ip" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.platform_firewall_public_ip_name
  allocation_method = "Static"  // static public ip for firewall
  sku = "Standard"

  tags = local.common_tags
}


# =================================
# Bastion Host - for secure admin access
# =================================
# Public IP for Bastion
resource "azurerm_public_ip" "bastion_host_public_ip" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.bastion_host_public_ip_name
  allocation_method = "Static"
  sku = "Standard"

  tags = local.common_tags
}
# Bastion Host
resource "azurerm_bastion_host" "cnsoln_bastion_host" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.bastion_host_name
  sku = "Standard"

  ip_configuration {
    name = "${var.bastion_host_name}-ipconfig"
    subnet_id = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_host_public_ip.id
  }

  tags = local.common_tags
}



# =================================
# AMPLS - for centralized monitoring
# =================================
# AMPLS - Azure Monitor Private Link Scope
# AMPLS logs - covered in Activity logs (monitoring module)
resource "azurerm_monitor_private_link_scope" "ampls_hub" {
  resource_group_name = var.rg_name
  name = var.ampls_name

  tags = local.common_tags
}

# AMPLS to LAW link (AMPS <--> LAW)
resource "azurerm_monitor_private_link_scoped_service" "ampls_hub_link_to_law" {
  resource_group_name = var.rg_name
  name = var.ampls_hub_link_to_law_name
  scope_name = azurerm_monitor_private_link_scope.ampls_hub.name  // AMPLS
  linked_resource_id = var.law_id   // LAW - from monitoring module
}


# Private endpoint for Azure Monitor - connected to AMPLS
# Private endpoint logs - covered in Activity logs (monitoring module)
resource "azurerm_private_endpoint" "monitor_pe" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.monitor_pe_name
  subnet_id = azurerm_subnet.private_endpoints_subnet.id   // monitor PE - stored in private endpoints subnet

  private_service_connection {
    name = "${var.ampls_name}-pe-connection"
    private_connection_resource_id = azurerm_monitor_private_link_scope.ampls_hub.id  //AMPLS id
    subresource_names = ["azuremonitor"]   // for azuremonitor subresource
    is_manual_connection = false
  }
  // no need for private dns zone group link - as monitor has multiple endpoints

  tags = local.common_tags
}

/* 
Private DNS zones for monitor, oms & ods are needed as I have opted for (in LAW)
 - internet_ingestion_enabled = false
 - internet_query_enabled     = false
So public endpoints for ingestion and query are blocked
In other words, in order to ingest or query logs, one must be connected to private network

** Also, no need to link these 3 private DNS zones to AMPLS - if both are in the same vnet
*/

# Private DNS zone logs - already covered in Activity logs (monitoring module)

# Private DNS zones for monitor, oms (ingestion), ods (query)
resource "azurerm_private_dns_zone" "monitor_private_dns_zone" {
  name = "privatelink.monitor.azure.com"  // has to be this name for monitor private DNS zone
  resource_group_name = var.rg_name
  
  tags = local.common_tags
}
resource "azurerm_private_dns_zone" "oms_private_dns_zone" {
  name = "privatelink.oms.opinsights.azure.com"   // has to be this name for ods private DNS zone
  resource_group_name = var.rg_name

  tags = local.common_tags
}
resource "azurerm_private_dns_zone" "ods_private_dns_zone" {
  name = "privatelink.ods.opinsights.azure.com"   // has to be this name for oms private DNS zone
  resource_group_name = var.rg_name

  tags = local.common_tags
}
