# variables.tf for env: prod

# ---------------------------------------------

# -----------------------------
# Module: platform
# -----------------------------
variable "subscription_id" {
  type = string
}
variable "tenant_root_group_id" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "rg_name" {
  type    = string
}
variable "rg_location" {
  type    = string
}
variable "cnsolns_recovery_services_vault_name" {
  type = string
}

# -----------------------------
# Module: monitoring
# -----------------------------
variable "alert_reciever_email" {
  type = string
}


# -----------------------------
# Module: hub-network
# -----------------------------
variable "hub_vnet_name" {
  type        = string
}
variable "hub_vnet_address_space" {
  type = list(string)
}
# Subnets
variable "firewall_subnet_name" {
  type        = string
}
variable "firewall_subnet_cidr" {
  type = list(string)
}
variable "bastion_subnet_name" {
  type        = string
}
variable "bastion_subnet_cidr" {
  type = list(string)
}
variable "gateway_subnet_name" {
  type        = string
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

# -----------------------------
# Module: spoke-network
# -----------------------------
variable "spoke_vnet_name" {
  type = string
}
variable "spoke_vnet_address_space" {
  type = list(string)
}
# Subnets
variable "app_subnet_name" {
  type = string
}
variable "app_subnet_cidr" {
  type = list(string)
}
variable "database_subnet_name" {
  type = string
}
variable "database_subnet_cidr" {
  type = list(string)
}
variable "workload_subnet_name" {
  type = string
}
variable "workload_subnet_cidr" {
  type = list(string)
}

# -----------------------------
# Module: compute
# -----------------------------
variable "win_vm_private_ip_address" {
  type = string
}

# -----------------------------
# Module: paas-resources (*********)
# -----------------------------
variable "github_client_id" {
  type = string
  default = null
}

