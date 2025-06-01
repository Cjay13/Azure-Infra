
resource "azurerm_virtual_network" "user-management" {
  name                = "user-management-vnet"
  location            = data.azurerm_resource_group.user-management.location
  resource_group_name = data.azurerm_resource_group.user-management.name
  address_space       = [var.vnet_cidr_range]


  tags = {
    project = "user-management"
  }
}

resource "azurerm_subnet" "aks-subnet" {
  name = "aks-subnet"
  resource_group_name = data.azurerm_resource_group.user-management.name
  virtual_network_name = azurerm_virtual_network.user-management.name
  address_prefixes = [var.aks_subnet_cidr_range]
}

resource "azurerm_subnet" "db-subnet" {
  name = "db-subnet"
  resource_group_name = data.azurerm_resource_group.user-management.name
  virtual_network_name = azurerm_virtual_network.user-management.name
  address_prefixes = [var.db_subnet_cidr_range]
}

locals {
  aks_subnet_cidr = azurerm_subnet.aks-subnet.address_prefixes[0]
  db_subnet_cidr = azurerm_subnet.db-subnet.address_prefixes[0]
}

resource "azurerm_network_security_group" "db-nsg" {
  name                = "db-nsg"
  location            = data.azurerm_resource_group.user-management.location
  resource_group_name = data.azurerm_resource_group.user-management.name
  security_rule {
    name = "db-access"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    source_address_prefix = local.aks_subnet_cidr
    destination_port_range = var.db_port
    destination_address_prefix = local.db_subnet_cidr

  } 
}

resource "azurerm_network_security_group" "aks-nsg" {
  name                = "aks-nsg"
  location            = data.azurerm_resource_group.user-management.location
  resource_group_name = data.azurerm_resource_group.user-management.name
  security_rule {
    name = "aks-access"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    source_address_prefix = "*"
    destination_port_ranges = [80, 443]
    destination_address_prefix = local.aks_subnet_cidr

  } 
}

resource "azurerm_subnet_network_security_group_association" "db-association" {
  subnet_id = azurerm_subnet.db-subnet.id
  network_security_group_id = azurerm_network_security_group.db-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "aks-association" {
  subnet_id = azurerm_subnet.aks-subnet.id
  network_security_group_id = azurerm_network_security_group.aks-nsg.id
}

