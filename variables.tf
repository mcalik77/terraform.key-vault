terraform {
  experiments = [module_variable_optional_attrs]
}

variable "secrets_list" {
  type        = list(map(string))
  description = "List of maps containing key, value pairs of secrets to add to an Azure Key-Vault"
  default     = []
}

variable "keys_list" {
  description = "List of maps containing key, value pairs of keys to add to an Azure Key-Vault"
  default     = []
}

variable "certs_list" {
  type        = list(map(string))
  description = "List of maps containing key, value pairs of certificates to add to an Azure Key-Vault"
  default     = []
}

variable "location" {
  type        = string
  description = "Azure Region to build resources in."
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name to build Azure resources in."
}


variable "enabled_for_disk_encryption" {
  description = "Determines if Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  default     = false
}

variable "sku" {
  type        = string
  description = "Azure Key-Vault SKU"
}

variable "info" {
  type = object({
    domain      = string
    subdomain   = string
    environment = string
    sequence    = string
  })
}

variable "tags" {
  type = map(string)
}


variable "ip_rules_list" {
  description = "List of public ip or ip ranges in CIDR Format to allow."
  default     = ["204.153.155.151/32"]
}

variable "subnet_whitelist" {
  type = list(object({
    virtual_network_name                = string
    virtual_network_subnet_name         = string
    virtual_network_resource_group_name = string
  }))

  description = "List of objects that contains information to look up a subnet. This is a whitelist of subnets to allow for the storage account."
  default     = []
}

variable private_endpoint_enabled {
  type        = bool
  description = "Determines if private endpoint should be enabled for the key vault."

  default = true
}

variable private_endpoint_subnet {
  type = object({
    virtual_network_name                = string
    virtual_network_subnet_name         = string
    virtual_network_resource_group_name = string
  })

  description = "Object that contains information to lookup the subnet to use for the privat endpoint."

  default = {
    virtual_network_name                = null
    virtual_network_subnet_name         = null
    virtual_network_resource_group_name = null
  }
}

variable enable_rbac_authorization {
  type    = bool
  default = true
  description = "It is enabling key-vault to have Azure role-based access control"
}

variable managed_identities {
  type = list(object({
    principal_name = string
    roles          = optional(list(string))
  }))
  description = "The name of manage identities(Service principal or Application name) to give key-vault access"
}
