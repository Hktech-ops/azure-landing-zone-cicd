# variables.tf for module: firewall

#############################################
# Resource Group (referenced from module: platform)
#############################################
variable "rg_name" {
}
variable "rg_location" {
}

# Firewall subnet id - referenced from module: hub-network
variable "firewall_subnet_id" {
}

# Platform firewall public ip id - from module: hub-network
variable "platform_firewall_public_ip_id" {
}


# LAW id - referenced from module: monitoring
variable "law_id" {
}




#############################################
# Firewall Configuration
#############################################
variable "platform_firewall_name" {
  type        = string
  default     = "platform-firewall"
}
variable "platform_firewall_diagnostic_setting" {
  type        = string
  default     = "platform-firewall-diagnostic-setting"
}

# from module: firewall-policies
variable "platform_firewall_policy_id" {
  type        = string
}

