data "azurerm_resource_group" "user-management" {
    name = var.resource_group_name
}

data "azurerm_key_vault" "cjaydevops-key-vault" {
  name                = "cjaydevops-key-vault"
  resource_group_name = data.azurerm_resource_group.user-management.name
}