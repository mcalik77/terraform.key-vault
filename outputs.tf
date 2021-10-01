output "key_vault_uri" {
  description = "The uri of the Key Vault, used for performing operations on keys and secrets."
  value       = azurerm_key_vault.key_vault.*.vault_uri[0]
}

output "name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.key_vault.name
}

output "disk_encryption_set_id" {
  description = "The ID of the disk encryption set used to encrypt the OS disk."
  value       = var.enabled_for_disk_encryption ? azurerm_disk_encryption_set.disk_encryption[0].id : null
}

output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.key_vault.id
}

output "secrets" {
  description = "References to keyvaults created"
  value       = [
    for secret in azurerm_key_vault_secret.secret_list_configs: {
      id = secret.id
      version = secret.version
    }
  ]
}

output "object_id" {
  value = data.azurerm_client_config.current.object_id
}

