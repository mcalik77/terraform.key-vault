locals {
  managed_identities = flatten([
    for identity in var.managed_identities : [
      {
        principal_name = identity.principal_name
        roles          = coalescelist(identity.roles, ["Key Vault Secrets User"])
      }
    ]
  ])
  role_assignments = flatten([
    for item in local.managed_identities : [
      for role in item.roles : {
        principal_name = item.principal_name
        role           = role
      }
    ]
  ])
}

# resource null_resource azure_login {
#   provisioner local-exec {
#     interpreter = ["/bin/bash", "-c"]
#     command = <<EOF
#       az login --service-principal \
#         --username $ARM_CLIENT_ID \
#         --password $ARM_CLIENT_SECRET \
#         --tenant $ARM_TENANT_ID

#       az account set --subscription $ARM_SUBSCRIPTION_ID 
#     EOF
#   }

#   triggers = {
#     always = uuid()
#   }
# }

# resource null_resource disable_triggers {
#   provisioner local-exec {
#     interpreter = ["/bin/bash", "-c"]
#     command = <<EOF
#        exists=0
#        count=0
#        until [ $exists != 0 ] || [ $count -gt 10 ] 
#          do
#           exists=$(az ad sp list --display-name appapptestingcommond008 | jq '. | length')
#           sleep 30 
#           count=`expr $count + 1` 
#        done
#     EOF

#   }
#   triggers = {
#     always = uuid()
#   }
#   depends_on = [null_resource.azure_login]
# }
resource null_resource previous {}

resource time_sleep wait_300_seconds {
  depends_on = [null_resource.previous]

  create_duration = "300s"
}

# This resource will create (at least) 30 seconds after null_resource.previous
resource null_resource next {
  depends_on = [time_sleep.wait_300_seconds]
}

data azuread_service_principal app {
  for_each = {
     for identity in var.managed_identities : identity.principal_name => identity
  }
  display_name = each.value.principal_name

  depends_on = [
    null_resource.next
  ]
}

data "azurerm_client_config" "current" {}


resource azurerm_role_assignment role_assignment {
  for_each = {
     for index, role in local.role_assignments : index => role
  }
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = each.value.role
  principal_id         = data.azuread_service_principal.app[each.value.principal_name].object_id
}
