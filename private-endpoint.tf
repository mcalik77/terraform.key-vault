module private_endpoint {
  count = var.private_endpoint_enabled ? 1 : 0

  source = "git::git@ssh.dev.azure.com:v3/AZBlue/OneAZBlue/terraform.devops.private-endpoint?ref=v0.0.6"

  info = var.info
  tags = local.merged_tags

  resource_group_name = var.resource_group_name
  location            = var.location

  resource_id       = azurerm_key_vault.key_vault.id
  subresource_names = ["vault"]

  private_endpoint_subnet = var.private_endpoint_subnet
}