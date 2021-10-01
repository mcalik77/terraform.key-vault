provider azurerm {
  features {}
}

module resource_group {
  source = "git::git@ssh.dev.azure.com:v3/AZBlue/OneAZBlue/terraform.devops.resource-group?ref=v1.0.0"

  info = {
    domain      = "Key"
    subdomain   = "Vault"
    environment = "Dev"
    sequence    = 4
  }
  tags = {}

  location = "South Central US"
}

module "kv" {
    source = "../"
    info = {
        domain      = "Key"
        subdomain   = "Vault"
        environment = "Dev"
        sequence    = 7
    }
    location = module.resource_group.location
    resource_group_name = module.resource_group.name

    secrets_list = [
        {
            key   = "secret1"
            value = module.resource_group.name
        },
        {
            key   = "secret2"
            value = "secret_value1"
        },
        {
            key   = "secret3"
            value = "secret_value1"
        },
        {
            key   = "secret4"
            value = "secret_value1"
        }
    ]


    sku = "standard"

    private_endpoint_subnet = {
        virtual_network_name                = "vnetVelConD01"
        virtual_network_subnet_name         = "privateLink01"
        virtual_network_resource_group_name = "spokeVnetRg"
    }



    tags = {
        environment = "Dev"
    }

    managed_identities = [
     {
        principal_name = "spJenkinsVelocityConnectDevTest" // service principal name 
        # roles = ["Key Vault Administrator", "Key Vault Certificates Officer"]
     },
     { 
       principal_name = "appangularapid001" // application name
       roles = ["Key Vault Administrator", "Key Vault Secrets User"]
     }
    ]
    
   
}
