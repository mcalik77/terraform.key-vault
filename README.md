# Azure Key-Vault

Terraform module that provisions a Key-Vault on Azure. Make sure to use terraform version 0.15.0 and higher 

# Possible built in roles for keyvault

https://docs.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli

# Usage

You can include the module by using the following code:

```


module "kv" {
  source = "git::git@ssh.dev.azure.com:v3/AZBlue/OneAZBlue/terraform.devops.key-vault?ref=v3.0.0"
  
  info = {
    domain      = "Key"
    subdomain   = "Vault"
    environment = "Dev"
    sequence    = 1
  }

  location            = "South Central US"
  resource_group_name = "rgTestKeyVault"

  secrets_list = [
    {
      key   = "secret1"
      value = "secret_value1"
    }
  ]

  sku = "standard"
  
  managed_identities = [
     {
        principal_name = "spJenkinsVelocityConnectDevTest" // service principal name 
        roles = ["Key Vault Administrator", "Key Vault Certificates Officer"]
     },
     { 
       principal_name = "appangularapid001" // application name
       roles = ["Key Vault Administrator", "Key Vault Secrets User"]
     }
    ]

  tags = {
    environment = "Dev"
  }
}
```

You can specify the values of the variables through a **tfvars** file or from
the command line. If needed you can even do a combination of the two by
specifying the **-var** and **-var-file** command line arguments.

## dev.tfvars

```
info = {
  domain      = "edi"
  subdomain   = "cache"
  environment = "dev"
  sequence    = "002"
}

tags = {
  source  = "terraform"
  project = "Velocity Connect"
  owner   = "Anna Koval"
}

location = "southcentralus"

enabled_for_disk_encryption = true

secrets_list = [
  {
    key   = "Redis--CacheExpirationInMinutes"
    value = "30"
  },
  {
    key   = "Serilog--Enrich--0"
    value = "FromLogContext"
  }
]

managed_identities = [
     {
        principal_name = "spJenkinsVelocityConnectDevTest" // service principal name 
        roles = ["Key Vault Administrator", "Key Vault Certificates Officer"] 
     },
     { 
       principal_name = "appangularapid001" // application name
       roles = ["Key Vault Administrator", "Key Vault Secrets User"]
     }
    ]


ip_rules_list = "204.153.155.151/32"
```


## Inputs

The following are the supported inputs for the module.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| info | Info object used to construct naming convention for all resources. | `object` | n/a | yes |
| tags | Tags object used to tag resources. | `object` | n/a | yes |
| resource_group | Name of the resource group where the data factory will be deployed. | `string` | n/a | yes |
| location | Region where all the resources will be created. | `string` | n/a | yes |
| sku | he Name of the SKU used for this Key Vault. Possible values are standard and premium. | `string` | n/a | yes |
| purge_protection_enabled | Determines if purge protection should be enabled for the key vault. | `boolean` | true | no |
| soft_delete_retention_days | The number of days that items should be retained for once soft-deleted. | `number` | 30 | no |
| enabled_for_disk_encryption | Determines if Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. | `boolean` | false | no |
| secrets_list | List of objects containing attributes for a secret to add to the key vault. | `list(object)` | n/a | no |
| keys_list | List of objects containing attributes for a key to add to the key vault. | `list(object)` | n/a | no |
| certs_list | List of objects containing attributes for a certificate to add to the key vault. | `list(object)` | n/a | yes |
| enable_rbac_authorization | Determines if rbac should be enabled for the key vault. | `bool` | true | no |
| managed_identities | The name of manage identities(Service principal or Application name) to give key-vault access | `list(object)` | n/a | no |
| service_principles | The name of service_principles assingning to the role | `list(string)` | [] | no |
| ip_rules_list | List of public ip or ip ranges in CIDR Format to allow. | `string` | `204.153.155.151/32` | no |
| subnet_whitelist | List of objects that contains information to look up a subnet. This is a whitelist of subnets to allow for the key-vault. | `list(object)` | `[]` | no |
| private_endpoint_enabled | Determines if private endpoint should be enabled for the key vault. | `bool` | true | no |
| private_endpoint_subnet | Object that contains information to lookup the subnet to use for the privat endpoint. When **private_endpoint_enabled** is set to true this variable is required, otherwise it is optional | `object` | n/a | no |
