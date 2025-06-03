resource "azurerm_container_registry" "cjaydevopsacr" {
  name                = "cjaydevopsacr"
  resource_group_name = data.azurerm_resource_group.user-management.name
  location            = data.azurerm_resource_group.user-management.location
  sku                 = "Standard"
  admin_enabled       = false

  identity {
    type = "SystemAssigned"
  }
}
