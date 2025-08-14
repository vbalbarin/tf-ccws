locals {
  service_ports = {
    all     = ["0-65535"]
    bastion = ["8080", "5701"]
    https   = ["443"]
    http    = ["80"]
    ssh     = ["22"]
    lustre  = ["988", "1019-1023"]
    # 111: portmapper, 635: mountd, 2049: nfsd, 4045: nlockmgr, 4046: status, 4049: rquotad
    nfs = ["111", "635", "2049", "4045", "4046", "4049"]
    #  HTTPS, AMQP
    cyclecloud = ["9443", "5672"]
    mysql      = ["3306", "33060"]
    ssh_rdp    = ["22", "3389"]
  }
}

locals {
  default_ccws_nsg_rules = {
    # Inbound default_ccws_nsg_rules priority range [100, 200)
    "AllowHttpsIn" = {
      name                       = "AllowHttpsIn"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["https"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
    "AllowSshVnetVnetIn" = {
      name                       = "AllowSshVnetVnetIn"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["ssh"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
    "AllowAllComputeComputeIn" = {
      name                       = "AllowAllComputeComputeIn"
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["all"]
      source_address_prefix      = module.subnet_addrs.network_cidr_blocks["ccw-compute-subnet"]
      destination_address_prefix = module.subnet_addrs.network_cidr_blocks["ccw-compute-subnet"]
      source_port_range          = "*"
    }
    "AllowCycleClientComputeIn" = {
      name                       = "AllowCycleClientComputeIn"
      priority                   = 140
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["cyclecloud"]
      source_address_prefix      = module.subnet_addrs.network_cidr_blocks["ccw-compute-subnet"]
      destination_address_prefix = module.subnet_addrs.network_cidr_blocks["ccw-cyclecloud-subnet"]
      source_port_range          = "*"
    }
    # Outbound default_ccws_nsg_rules priority range [100, 200)
    "AllowHttpsOut" = {
      name                       = "AllowHttpsOut"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["https"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
    "AllowSshCyclecloudComputeOut" = {
      name                       = "AllowSshCyclecloudComputeOut"
      priority                   = 120
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["ssh"]
      source_address_prefix      = module.subnet_addrs.network_cidr_blocks["ccw-cyclecloud-subnet"]
      destination_address_prefix = module.subnet_addrs.network_cidr_blocks["ccw-compute-subnet"]
      source_port_range          = "*"
    }
    "AllowCycleClientComputeOut" = {
      name                       = "AllowCycleClientComputeOut"
      priority                   = 130
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["cyclecloud"]
      source_address_prefix      = module.subnet_addrs.network_cidr_blocks["ccw-compute-subnet"]
      destination_address_prefix = module.subnet_addrs.network_cidr_blocks["ccw-cyclecloud-subnet"]
      source_port_range          = "*"
    }
    "AllowAllComputeComputeOut" = {
      name                       = "AllowAllComputeComputeOut"
      priority                   = 140
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["all"]
      source_address_prefix      = module.subnet_addrs.network_cidr_blocks["ccw-compute-subnet"]
      destination_address_prefix = module.subnet_addrs.network_cidr_blocks["ccw-compute-subnet"]
      source_port_range          = "*"
    }
    "AllowInternetOutBound" = {
      name                       = "AllowInternetOutBound"
      priority                   = 150
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["all"]
      source_address_prefix      = "Virtualnetwork"
      destination_address_prefix = "Internet"
      source_port_range          = "*"
    }

  }
  bastion_tgt_vm_nsg_rules = {
    # Inbound bastion_tgt_vm_nsg_rules [210, 300)
    "AllowSshRdpBastionSvcIn" = {
      name                       = "AllowSshRdpBastionSvcIn"
      priority                   = 210
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["ssh_rdp"]
      source_address_prefix      = module.subnet_addrs.network_cidr_blocks["AzureBastionSubnet"]
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
    # Outbound bastion_tgt_vm_nsg_rules [210, 300)
    "AllowSshRdpBastionSvcOut" = {
      name                       = "AllowSshRdpBastionSvcOut"
      priority                   = 210
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      destination_port_ranges    = local.service_ports["ssh_rdp"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      source_port_range          = "*"
    }
  }
  base_bastion_nsg_rules = {
    # Inbound base_bastion_nsg_rules [310, 400)
    "AllowHttpsBastionIn" = {
      name                    = "AllowHttpsBastionIn"
      priority                = 310
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      destination_port_ranges = local.service_ports["https"]
      source_address_prefix   = "Internet"
      #   destination_address_prefix = module.subnet_addrs.network_cidr_blocks["AzureBastionSubnet"]
      destination_address_prefix = "*"
      source_port_range          = "*"
    }
    "AllowGatewayManagerBastionIn" = {
      name                       = "AllowGatewayManagerBastionIn"
      priority                   = 320
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["https"]
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
      source_port_range          = "*"
    }
    "AllowAzureLoadBalancerBastionIn" = {
      name                       = "AllowAzureLoadBalancerBastionIn"
      priority                   = 330
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["https"]
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      source_port_range          = "*"
    }
    "AllowBastionHostCommunicationBastionIn" = {
      name                       = "AllowBastionHostCommunicationBastionIn"
      priority                   = 340
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["bastion"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
    "AllowSshRdpBastionClientIn" = {
      name                       = "AllowSshRdpBastionTgtIn"
      priority                   = 350
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["ssh_rdp"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = module.subnet_addrs.network_cidr_blocks["AzureBastionSubnet"]
      source_port_range          = "*"
    }
    # Outbound base_bastion_nsg_rules [310, 400)
    "AllowSshRdpBastionTgtVmOut" = {
      name                       = "AllowSshRdpBastionTgtVmOut"
      priority                   = 310
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      destination_port_ranges    = local.service_ports["ssh_rdp"]
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
    "AllowAzureCloudBastionOut" = {
      name                       = "AllowAzureCloudBastionOut"
      priority                   = 320
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["https"]
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud"
      source_port_range          = "*"
    }
    "AllowBastionHostCommunicationBastionOut" = {
      name                       = "AllowBastionHostCommunicationBastionOut"
      priority                   = 330
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      destination_port_ranges    = local.service_ports["bastion"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
    "AllowHttpBastionOut" = {
      name                       = "AllowHttpBastionOut"
      priority                   = 340
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      destination_port_ranges    = local.service_ports["http"]
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
      source_port_range          = "*"
    }
    "AllowHttpsBastionOut" = {
      name                       = "AllowHttpsBastionOut"
      priority                   = 350
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["https"]
      source_address_prefix      = module.subnet_addrs.network_cidr_blocks["AzureBastionSubnet"]
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
  }
  default_deny_nsg_rules = {
    "DenyVnetInbound" = {
      name                       = "DenyVnetInbound"
      priority                   = 4095
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["all"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
    "DenyVnetOutbound" = {
      name                       = "DenyVnetOutbound"
      priority                   = 4095
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "Tcp"
      destination_port_ranges    = local.service_ports["all"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      source_port_range          = "*"
    }
  }
  common_ccws_nsg_rules = merge(
    local.default_ccws_nsg_rules,
    var.deploy_bastion ? local.bastion_tgt_vm_nsg_rules : {},
    local.default_deny_nsg_rules
  )
  bastion_nsg_rules = merge(
    local.base_bastion_nsg_rules,
    local.default_deny_nsg_rules
  )
}

# output "debug" {
#   value       = local.common_ccws_nsg_rules
#   description = "debug"
# }

module "common_ccws_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.4.0"

  name                = replace(local.resource_names["network_security_group_name"], var.resource_name_workload, "common-${var.resource_name_workload}")
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location


  security_rules = local.common_ccws_nsg_rules

  tags             = var.tags
  enable_telemetry = var.telemetry_enabled
}

module "bastion_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.4.0"

  #count = var.deploy_bastion ? 1 : 0

  name                = replace(local.resource_names["network_security_group_name"], var.resource_name_workload, "bastion-${var.resource_name_workload}")
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location


  security_rules = local.bastion_nsg_rules

  tags             = var.tags
  enable_telemetry = var.telemetry_enabled
}