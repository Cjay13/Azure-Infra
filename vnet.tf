resource "azurerm_network_security_group" "user-management-nsg" {
  name                = "user-management-nsg"
  location            = data.azurerm_resource_group.user-management.location
  resource_group_name = data.azurerm_resource_group.user-management.name
}

resource "azurerm_virtual_network" "example" {
  name                = "user-management-vnet"
  location            = data.azurerm_resource_group.user-management.location
  resource_group_name = data.azurerm_resource_group.user-management.name
  address_space       = ["10.1.0.0/26"]


  subnet {
    name             = "subnet1"
    address_prefixes = ["10.1.0.0/27"]
    security_group   = azurerm_network_security_group.user-management-nsg.id
  }

  subnet {
    name             = "subnet2"
    address_prefixes = ["10.1.0.32/27"]
    security_group   = azurerm_network_security_group.user-management-nsg.id
  }


  tags = {
    project = "user-management"
  }
}