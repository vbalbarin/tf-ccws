variable "workload_subscription_id" {
  type = string
}


variable "system_assigned_managed_id" {
  default     = ""
  type        = string
  description = "System assigned managed identity that will be given access to the Terraform state file. If empty, a user assigned managed identity will be created."
}

variable "location" {
  type        = string
  description = "The location/region where the resources will be created. Must be in the short form (e.g. 'uksouth')"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.location))
    error_message = "The location must only contain lowercase letters, numbers, and hyphens"
  }
  validation {
    condition     = length(var.location) <= 20
    error_message = "The location must be 20 characters or less"
  }
}

variable "resource_name_location_short" {
  type        = string
  description = "The short name segment for the location. If left blank, this will be calculated using Azure/avm-utl-regions/azurerm."
  default     = ""
  validation {
    condition     = length(var.resource_name_location_short) == 0 || can(regex("^[a-z]+$", var.resource_name_location_short))
    error_message = "The short name segment for the location must only contain lowercase letters"
  }
  validation {
    condition     = length(var.resource_name_location_short) <= 3
    error_message = "The short name segment for the location must be 3 characters or less"
  }
}

variable "resource_name_workload" {
  type        = string
  description = "The name segment for the workload"
  default     = "dema"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_workload))
    error_message = "The name segment for the workload must only contain lowercase letters and numbers"
  }
  validation {
    condition     = length(var.resource_name_workload) <= 4
    error_message = "The name segment for the workload must be 4 characters or less"
  }
}

variable "resource_name_environment" {
  type        = string
  description = "The name segment for the environment"
  default     = "dem"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_environment))
    error_message = "The name segment for the environment must only contain lowercase letters and numbers"
  }
  validation {
    condition     = length(var.resource_name_environment) <= 4
    error_message = "The name segment for the environment must be 4 characters or less"
  }
}

variable "resource_name_sequence_start" {
  type        = number
  description = "The number to use for the resource names"
  default     = 1
  validation {
    condition     = var.resource_name_sequence_start >= 1 && var.resource_name_sequence_start <= 999
    error_message = "The number must be between 1 and 999"
  }
}


variable "resource_name_templates" {
  type        = map(string)
  description = "A map of resource names to use"
  default = {
    resource_group_state_name      = "rg-$${workload}-tfstate-$${environment}-$${location_short}-$${sequence}"
    storage_account_name           = "sto$${workload}$${environment}$${location_short}$${sequence}$${uniqueness}"
    resource_group_identity_name   = "rg-$${workload}-identity-$${environment}-$${location_short}-$${sequence}"
    resource_group_network_name    = "rg-$${workload}-network-$${environment}-$${location_short}-$${sequence}"
    user_assigned_managed_identity = "umi-$${workload}-$${environment}-$${location_short}-$${sequence}"

    # resource_group_agents_name            = "rg-$${workload}-agents-$${environment}-$${location_short}-$${sequence}"
    virtual_network_name        = "vnet-$${workload}-$${environment}-$${location_short}-$${sequence}"
    network_security_group_name = "nsg-$${workload}-$${environment}-$${location_short}-$${sequence}"
    bastion_name                = "bastion-$${workload}-$${environment}-$${location_short}-$${sequence}"
    bastion_public_ip_name      = "pip-bastion-$${workload}-$${environment}-$${location_short}-$${sequence}"
    nat_gateway_name                      = "nat-$${workload}-$${environment}-$${location_short}-$${sequence}"
    nat_gateway_public_ip_name            = "pip-nat-$${workload}-$${environment}-$${location_short}-$${sequence}"
    # storage_account_private_endpoint_name = "pe-sto-$${workload}-$${environment}-$${location_short}-$${sequence}"
    # agent_compute_postfix_name            = "$${workload}-$${environment}-$${location_short}-$${sequence}"
    # container_instance_prefix_name        = "aci-$${workload}-$${environment}-$${location_short}"
    # container_registry_name               = "acr$${workload}$${environment}$${location_short}$${sequence}$${uniqueness}"
    # project_name                          = "$${workload}-$${environment}"
    # repository_main_name                  = "$${workload}-$${environment}-main"
    # repository_template_name              = "$${workload}-$${environment}-template"
    # agent_pool_name                       = "agent-pool-$${workload}-$${environment}"
    # group_name                            = "group-$${workload}-$${environment}-approvers"
  }
}

variable "vnet_address_space" {
  default = "10.1.0.0/22"
  type    = string
}

variable "deploy_bastion" {
  type    = bool
  default = true
}

variable "deploy_natgw" {
  type    = bool
  default = true
}

variable "telemetry_enabled" {
  default = false
  type    = bool
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}