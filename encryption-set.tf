resource "azurerm_key_vault_access_policy" "disk_encryption" {
  count = var.enabled_for_disk_encryption ? 1 : 0

  key_vault_id = azurerm_key_vault.key_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_disk_encryption_set.disk_encryption[0].identity[0].principal_id

  key_permissions = [
    "get",
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
}

resource "azurerm_key_vault_key" "key_list_config" {
  for_each = {
    for index, key in var.keys_list : index => key
  }

  name         = each.value.name
  key_vault_id = azurerm_key_vault.key_vault.id

  key_type = each.value.key_type
  key_size = each.value.key_size
  key_opts = each.value.key_opts

  tags = local.merged_tags

  depends_on = [
    azurerm_role_assignment.role_assignment
  ]
}

resource "azurerm_disk_encryption_set" "disk_encryption" {
  count = var.enabled_for_disk_encryption ? 1 : 0

  name = lower(format("%s%s%03d",
    substr(
      module.naming.disk_encryption_set.name, 0,
      module.naming.disk_encryption_set.max_length - 3
    ),
    substr(var.info.environment, 0, 1),
    var.info.sequence
  ))

  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = azurerm_key_vault_key.key_list_config[0].id

  identity {
    type = "SystemAssigned"
  }
}