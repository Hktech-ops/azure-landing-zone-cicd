# terraform.tfvars for env: test
# it serves as a global config file for vaules of the variables used in the project!

## In a real-world scenario, I would refrain from adding ids in tf.vars --> when pushing to git hub!
# --------------------------------------------------

# tenant_root_group_id --> CLI = az accout management-goup list
# subscription_id --> CLI = az account show --query id --> /subscriptions/"**<id>** 
# tenant id --> CLI = az account show


# -----------------------------
# Module: platform
# -----------------------------
tenant_root_group_id = "/providers/Microsoft.Management/managementGroups/2b4bb9a8-b0c8-415d-a87c-919dd639e8f5"
subscription_id      = "/subscriptions/1c1bf735-bff4-43f7-b6ed-9bfbb87f4840"
tenant_id = "2b4bb9a8-b0c8-415d-a87c-919dd639e8f5"
rg_name = "cnsolns-azure-landing-zone"
rg_location = "Canada Central"
cnsolns_recovery_services_vault_name = "cnsolns-recovery-services-vault"


# -----------------------------
# Module: monitoring
# -----------------------------
alert_reciever_email = "harsh.hk.ca@outlook.com"


# -----------------------------
# Module: hub-network
# -----------------------------
hub_vnet_name = "hub-vnet"
hub_vnet_address_space = [ "10.0.0.0/22" ]

firewall_subnet_name = "AzureFirewallSubnet"
firewall_subnet_cidr = [ "10.0.0.0/26" ]

bastion_subnet_name = "AzureBastionSubnet"
bastion_subnet_cidr = [ "10.0.0.64/26" ]

gateway_subnet_name = "GatewaySubnet"
gateway_subnet_cidr = [ "10.0.0.128/27" ]

private_endpoints_subnet_name = "private-endpoints-subnet"
private_endpoints_subnet_cidr = [ "10.0.1.0/24" ]

# -----------------------------
# Module: spoke-network
# -----------------------------
spoke_vnet_name = "spoke-vnet"
spoke_vnet_address_space = [ "192.168.0.0/22" ]

app_subnet_name = "app-subnet"
app_subnet_cidr = [ "192.168.0.0/24" ]

database_subnet_name = "database-subnet"
database_subnet_cidr = [ "192.168.1.0/24" ]

workload_subnet_name = "workload-subnet"
workload_subnet_cidr = [ "192.168.2.0/24" ]


# -----------------------------
# Module: compute
# -----------------------------
win_vm_private_ip_address = "192.168.0.4"


# -----------------------------
# Module: paas-resources
# -----------------------------
github_client_id = "86d2ea15-3b7f-4942-bf2a-18b122096f26"   // client id of SP