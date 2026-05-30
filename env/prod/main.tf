# main.tf for env: prod

# --------------------------------------

module "platform" {
  source = "../../modules/platform"

  # keyed values in tfvars
  subscription_id      = var.subscription_id       
  tenant_root_group_id = var.tenant_root_group_id

  # keyed values in tfvars
  rg_name = var.rg_name  
  rg_location = var.rg_location   

  # keyed values in tfvars
  cnsolns_recovery_services_vault_name = var.cnsolns_recovery_services_vault_name 
}

module "monitoring" {
  source = "../../modules/monitoring"

  # referenced from platform module
  rg_name     = module.platform.rg_name     
  rg_location = module.platform.rg_location

  # keyed value in tfvars
  alert_reciever_email = var.alert_reciever_email   
}

module "policies" {
  source = "../../modules/policies"

  # referenced from platform module
  rg_location          = module.platform.rg_location
  workloads_corp_mg_id = module.platform.workloads_corp_mg_id 

  # referenced from monitoring module
  law_id               = module.monitoring.law_id       

  # keyed value in tfvars
  subscription_id      = var.subscription_id
}

module "iam" {
  source = "../../modules/iam"
}


module "hub-network" {
  source = "../../modules/hub-network"

  # referenced from platform module
  rg_name     = module.platform.rg_name     
  rg_location = module.platform.rg_location 

  # Keyed values in tfvars
  hub_vnet_name = var.hub_vnet_name
  hub_vnet_address_space = var.hub_vnet_address_space

  firewall_subnet_name = var.firewall_subnet_name
  firewall_subnet_cidr = var.firewall_subnet_cidr

  bastion_subnet_name = var.bastion_subnet_name
  bastion_subnet_cidr = var.bastion_subnet_cidr

  gateway_subnet_name = var.gateway_subnet_name
  gateway_subnet_cidr = var.gateway_subnet_cidr

  private_endpoints_subnet_name = var.private_endpoints_subnet_name
  private_endpoints_subnet_cidr = var.private_endpoints_subnet_cidr

  # referenced from monitoring module
  law_id      = module.monitoring.law_id    

}

module "firewall-policies" {
  source = "../../modules/firewall-policies"

  # from module: platfrom
  rg_name = module.platform.rg_name
  rg_location = module.platform.rg_location

  # from module: hub-network
  platform_firewall_public_ip_address = module.hub-network.platform_firewall_public_ip_address

  # keyed value in tfvars - app subnet defined in spoke-network
  app_subnet_cidr = var.app_subnet_cidr

  # keyed value in tfvars - win vm private ip defined in module: compute
  win_vm_private_ip_address = var.win_vm_private_ip_address

}

module "firewall" {
  source = "../../modules/firewall"

  # from module: platform
  rg_name = module.platform.rg_name
  rg_location = module.platform.rg_location

  # from module: monitoring
  law_id = module.monitoring.law_id   

  # from module: hub-network
  firewall_subnet_id = module.hub-network.firewall_subnet_id  
  platform_firewall_public_ip_id = module.hub-network.platform_firewall_public_ip_id

  # from module: firewall-policies
  platform_firewall_policy_id = module.firewall-policies.platform_firewall_policy_id  
}


module "spoke-network" {
  source = "../../modules/spoke-network"

  # from module: platform
  rg_name                = module.platform.rg_name
  rg_location            = module.platform.rg_location

  # keyed values in tfvars
  spoke_vnet_name = var.spoke_vnet_name
  spoke_vnet_address_space = var.spoke_vnet_address_space

  app_subnet_name = var.app_subnet_name
  app_subnet_cidr = var.app_subnet_cidr

  database_subnet_name = var.database_subnet_name
  database_subnet_cidr = var.database_subnet_cidr

  workload_subnet_name = var.workload_subnet_name
  workload_subnet_cidr = var.workload_subnet_cidr

  # from module: firewall
  platform_firewall_private_ip_address = module.firewall.platform_firewall_private_ip_address

  # from module: monitoring
  law_id                 = module.monitoring.law_id

  # from module: hub-network
  hub_vnet_name          = module.hub-network.hub_vnet_name
  hub_vnet_id            = module.hub-network.hub_vnet_id
  hub_vnet_address_space = module.hub-network.hub_vnet_address_space
  monitor_private_dns_zone_name = module.hub-network.monitor_private_dns_zone_name
  oms_private_dns_zone_name     = module.hub-network.oms_private_dns_zone_name
  ods_private_dns_zone_name     = module.hub-network.ods_private_dns_zone_name

}


module "paas-resources" {
  source = "../../modules/paas-resources"

  tenant_id                               = var.tenant_id

  # from module: platform
  rg_name                                 = module.platform.rg_name
  rg_location                             = module.platform.rg_location

  # from module: monitoring
  law_id                                  = module.monitoring.law_id

  # from module: paas-resources
  key_vault_admins_group_object_id        = module.iam.key_vault_admins_group_object_id
  acr_managers_group_object_id            = module.iam.acr_managers_group_object_id
  storage_ac_contributors_group_object_id = module.iam.storage_ac_contributors_group_object_id

  # from module: paas-resources --> keyed value in tfvars
  # github_client_id = var.github_client_id 

  # from module: hub-network
  hub_vnet_id                 = module.hub-network.hub_vnet_id
  spoke_vnet_id               = module.spoke-network.spoke_vnet_id
  private_endpoints_subnet_id = module.hub-network.private_endpoints_subnet_id

  # from module: iam
  sql_admins_object_id  = module.iam.sql_admins_group_object_id
  sql_admins_group_name = module.iam.sql_admins_group_name

  
}

module "compute" {
  source = "../../modules/compute"

  # form module: platform
  rg_name                              = module.platform.rg_name
  rg_location                          = module.platform.rg_location
  cnsolns_recovery_services_vault_name = module.platform.cnsolns_recovery_services_vault_name

  # from module: monitoring
  law_id                               = module.monitoring.law_id
  
  # from module: spoke-network
  app_subnet_id                        = module.spoke-network.app_subnet_id
  
  # from module: paas-resources
  storage_account_uri                  = module.paas-resources.storage_account_uri
  
  # from module: iam
  vm_admins_group_object_id            = module.iam.vm_admins_group_object_id
  
  # keyed value in tfvars
  win_vm_private_ip_address = var.win_vm_private_ip_address

}

/* module "app-service" {
  source = "../../modules/app-service"

  # from module: paltform
  rg_name = module.platform.rg_name
  rg_location = module.platform.rg_location

  # from module: monitoring
  law_id = module.monitoring.law_id
  
} */