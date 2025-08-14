module "nat_gateway" {
  count = var.deploy_natgw ? 1 : 0

  source  = "Azure/avm-res-network-natgateway/azurerm"
  version = "~> 0.2.1"

  name                = local.resource_names["nat_gateway_name"]
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  tags                = var.tags

  
  subnet_associations = {
    ccw-compute-subnet = {
      resource_id = module.virtualnetwork.subnets["ccw-compute-subnet"].resource_id
    }
    ccw-cyclecloud-subnet = {
      resource_id = module.virtualnetwork.subnets["ccw-cyclecloud-subnet"].resource_id
    }
  }

  public_ip_configuration = {
    allocation_method = "Static"
    ip_version        = "IPv4"
    sku               = "Standard"
    zones             = ["1", "2", "3"]
  }

  public_ips = {
    ng_pip1 = {
      name = local.resource_names["nat_gateway_public_ip_name"]
    }
  }

  enable_telemetry = var.telemetry_enabled
}