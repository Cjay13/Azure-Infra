
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

  delegation {
    name = "db-delegation"

    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "appgw-subnet" {
  name = "appgw-subnet"
  resource_group_name = data.azurerm_resource_group.user-management.name
  virtual_network_name = azurerm_virtual_network.user-management.name
  address_prefixes = [var.appgw_subnet_cidr_range]

  delegation {
    name = "appgw-delegation"

    service_delegation {
      name    = "Microsoft.Network/applicationGateways"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }  
}

resource "azurerm_subnet" "pvtep-subnet" {
  name = "pvtep-subnet"
  resource_group_name = data.azurerm_resource_group.user-management.name
  virtual_network_name = azurerm_virtual_network.user-management.name
  address_prefixes = [var.pvtep_subnet_cidr_range] 
}

locals {
  aks_subnet_cidr = azurerm_subnet.aks-subnet.address_prefixes[0]
  db_subnet_cidr = azurerm_subnet.db-subnet.address_prefixes[0]
  appgw_subnet_cidr = azurerm_subnet.appgw-subnet.address_prefixes[0]
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

resource "azurerm_network_security_group" "appgw-nsg" {
  name                = "appgw-nsg"
  location            = data.azurerm_resource_group.user-management.location
  resource_group_name = data.azurerm_resource_group.user-management.name
  security_rule {
    name = "appgw-infra-access"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    source_address_prefix = "Internet"
    destination_port_ranges = ["65200-65535"]
    destination_address_prefix = "*"

  } 

  security_rule {
  name                       = "appgw-web-access"
  priority                   = 110
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = "Internet"
  destination_port_ranges    = [80, 443]
  destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "pvtep-nsg" {
  name                = "pvtep-nsg"
  location            = data.azurerm_resource_group.user-management.location
  resource_group_name = data.azurerm_resource_group.user-management.name
  security_rule {
    name = "pvtep-access"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    source_address_prefix = local.aks_subnet_cidr
    destination_port_range = var.db_port
    destination_address_prefix = "*"
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

resource "azurerm_subnet_network_security_group_association" "appgw-association" {
  subnet_id = azurerm_subnet.appgw-subnet.id
  network_security_group_id = azurerm_network_security_group.appgw-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "pvtep-association" {
  subnet_id = azurerm_subnet.pvtep-subnet.id
  network_security_group_id = azurerm_network_security_group.pvtep-nsg.id
}

resource "azurerm_public_ip" "appgw-pip" {
  name                = "appgw-pip"
  resource_group_name = data.azurerm_resource_group.user-management.name
  location            = data.azurerm_resource_group.user-management.location
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "user-management-appgw" {
  name                = "user-management-appgw"
  resource_group_name = data.azurerm_resource_group.user-management.name
  location            = data.azurerm_resource_group.user-management.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw-subnet.id
  }

  frontend_port {
    name = "user-management-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "user-management-feip"
    public_ip_address_id = azurerm_public_ip.appgw-pip.id
  }

  backend_address_pool {
    name = "user-management-beap"
  }

  backend_http_settings {
    name                  = "user-management-be-httpst"
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "user-management-httplistner"
    frontend_ip_configuration_name = "user-management-feip"
    frontend_port_name             = "user-management-feport"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "user-management-rqrt-rule"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "user-management-httplistner"
    backend_address_pool_name  = "user-management-beap"
    backend_http_settings_name = "user-management-be-httpst"
  }
}

resource "azurerm_private_dns_zone" "db-pvt-dns-zone" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = data.azurerm_resource_group.user-management.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db-pvt-link" {
  name                  = "dbzonevnetlink"
  private_dns_zone_name = azurerm_private_dns_zone.db-pvt-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.user-management.id
  resource_group_name   = data.azurerm_resource_group.user-management.name
}

# resource "azurerm_private_endpoint" "mysql_private_endpoint" {
#   name                = "mysql-private-endpoint"
#   location            = data.azurerm_resource_group.user-management.location
#   resource_group_name = data.azurerm_resource_group.user-management.name
#   subnet_id           = azurerm_subnet.pvtep-subnet.id

#   private_service_connection {
#     name                           = "mysql-psc"
#     private_connection_resource_id = azurerm_mysql_flexible_server.user-management-mysql-server.id
#     is_manual_connection           = false
#     subresource_names              = ["mysqlServer"]
#   }
# }
