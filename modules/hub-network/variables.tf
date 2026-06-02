# variables.tf for module: hub-network


#############################################
# Resource Group (referenced from module: platform)
#############################################
variable "rg_name" {
}
variable "rg_location" {
}


#############################################
# Hub Virtual Network & Subnets - keyed values in tfvars (some left with default vaules intentionally to honor Azure naming conventions)
#############################################
variable "hub_vnet_name" {
  type        = string
}
variable "hub_vnet_address_space" {
  type = list(string)
}
# Subnet names
variable "firewall_subnet_name" {
  type        = string
  default     = "AzureFirewallSubnet"
}
variable "firewall_subnet_cidr" {
  type = list(string)
}
variable "bastion_subnet_name" {
  type        = string
  default     = "AzureBastionSubnet"
}
variable "bastion_subnet_cidr" {
  type = list(string)
}
variable "gateway_subnet_name" {
  type        = string
  default     = "GatewaySubnet"
}
variable "gateway_subnet_cidr" {
  type = list(string)
}
variable "private_endpoints_subnet_name" {
  type        = string
}
variable "private_endpoints_subnet_cidr" {
  type = list(string)
}

# ==========================
# Platform Firewall public IP
# ==========================
variable "platform_firewall_public_ip_name" {
  type        = string
  default     = "platform-firewall-public-ip"
}


#############################################
# Log Analytics Workspace (referenced from module: monitoring)
#############################################
variable "law_id" {
  type        = string
}

#############################################
# Azure Monitor Private Link Scope (AMPLS)
#############################################
variable "ampls_name" {
  type        = string
  default     = "ampls-monitoring"
}
variable "monitor_pe_name" {
  type        = string
  default     = "monitor-pe"
}
variable "ampls_hub_link_to_law_name" {
  type        = string
  default = "ampls-law-link"
}


#############################################
# Bastion Host Configuration
#############################################
variable "bastion_host_name" {
  description = "Name of the Azure Bastion host."
  type        = string
  default     = "cnsolns-bastion-host"
}
variable "bastion_host_public_ip_name" {
  description = "Name of the public IP resource for the Bastion host."
  type        = string
  default     = "bastion-host-public-ip"
}
