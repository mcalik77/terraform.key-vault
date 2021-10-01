terraform {
  required_version = ">= 0.13.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.40.0, != 2.45.0, != 2.45.1"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.2.2"
    }
  }
}

locals {
  merged_tags = merge(
    {
      for index, tag in var.tags: index => title(tag)
    }, 
    {
      subproject  = "${title(var.info.domain)}${title(var.info.subdomain)}"
      environment = title(var.info.environment)
      source      = "Terraform"
    }
  )

  name = regex("[a-z]+", var.info.domain)

  subnet_whitelist = [
    for subnet in data.azurerm_subnet.subnet : subnet.id
  ]
}

module "naming"  {
  #source  = "Azure/naming/azurerm"
  #version = "0.1.0"
  # since this module isnt properly managed with release tags we need to pull master
  source  = "github.com/Azure/terraform-azurerm-naming?ref=64b9489"
  suffix  = [ "${title(var.info.domain)}${title(var.info.subdomain)}" ]
}

data "azurerm_subnet" "subnet" {  
  for_each = {
    for key, subnet in var.subnet_whitelist: key => subnet
  }

  name                 = each.value.virtual_network_subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.virtual_network_resource_group_name
}

resource "azurerm_key_vault" "key_vault" {
  name = replace(
    format("%s%s%03d",
      substr(
        module.naming.key_vault.name, 0,
        module.naming.key_vault.max_length - 4
      ),
      substr(title(var.info.environment), 0, 1),
      title(var.info.sequence)
    ), "-", ""
  )

  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption   = var.enabled_for_disk_encryption
  purge_protection_enabled      = true
  soft_delete_retention_days  = 30 
  enable_rbac_authorization     = var.enable_rbac_authorization

  sku_name = var.sku

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.ip_rules_list
    virtual_network_subnet_ids = local.subnet_whitelist
  }

  tags = local.merged_tags
}

resource "azurerm_key_vault_secret" "secret_list_configs" {
  for_each = {
    for secret in var.secrets_list: secret.key => secret.value
  }

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.key_vault.id

  tags = local.merged_tags

  depends_on = [
    azurerm_role_assignment.role_assignment,
    module.private_endpoint
  ]
}
