module "subnet_addrs" {
  source  = "hashicorp/subnets/cidr"
  version = "~> 1.0.0"

  base_cidr_block = local.conf_network_resources.vnet_address_space
  networks = [
    {
      name     = "ccw-compute-subnet"
      new_bits = 1
    },
    {
      name     = "ccw-slurmdb-subnet"
      new_bits = 2
    },
    {
      name     = "ccw-cyclecloud-subnet"
      new_bits = 7
    },
    {
      name     = "ccw-storage-subnet"
      new_bits = 4
    },
    {
      name     = "AzureBastionSubnet"
      new_bits = 4
    },
  ]
}


module "virtualnetwork" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.8.1"

  // DO NOT SET DNS IPs HERE

  name                = local.resource_names["virtual_network_name"]
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location

  address_space = [local.conf_network_resources.vnet_address_space, ]

  subnets = {
    "ccw-compute-subnet" = {
      name             = "ccw-compute-subnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["ccw-compute-subnet"]]
      network_security_group = {
        id = module.common_ccws_nsg.resource.id
      }
    }
    "ccw-slurmdb-subnet" = {
      name             = "ccw-slurmdb-subnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["ccw-slurmdb-subnet"]]
      network_security_group = {
        id = module.common_ccws_nsg.resource.id
      }
      delegation = [{
        name = "Microsoft.DBforMySQL.flexibleServers"
        service_delegation = {
          name = "Microsoft.DBforMySQL/flexibleServers"
        }
      }]
    }
    "ccw-cyclecloud-subnet" = {
      name             = "ccw-cyclecloud-subnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["ccw-cyclecloud-subnet"]]
      network_security_group = {
        id = module.common_ccws_nsg.resource.id
      }
    }
    "ccw-storage-subnet" = {
      name             = "ccw-storage-subnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["ccw-storage-subnet"]]
      network_security_group = {
        id = module.common_ccws_nsg.resource.id
      }
      delegation = [{
        name = "Microsoft.Netapp.volumes"
        service_delegation = {
          name = "Microsoft.Netapp/volumes"
        }
      }]
    }
    "AzureBastionSubnet" = {
      name             = "AzureBastionSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["AzureBastionSubnet"]]
      network_security_group = {
        id = module.bastion_nsg.resource.id
      }
    }
  }

  enable_telemetry = var.telemetry_enabled

  tags = var.tags
}

# output "subnets" {
#   value = module.subnet_addrs.networks 
# }