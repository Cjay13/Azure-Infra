resource "random_password" "mysql_password" {
  length  = 16
  override_special = "!@#"
  special = true
  number = true
  lower = true
  upper = true

  min_special      = 1
  min_numeric      = 1
  min_upper        = 1
  min_lower        = 1
}

resource "azurerm_key_vault_secret" "mysql_password_secret" {
  name         = "mysql-admin-password"
  value        = random_password.mysql_password.result
  key_vault_id = data.azurerm_key_vault.cjaydevops-key-vault.id
}

resource "azurerm_mysql_flexible_server" "user-management-mysql-server" {
  name                   = "user-management-mysql-db"
  resource_group_name    = data.azurerm_resource_group.user-management.name
  location               = data.azurerm_resource_group.user-management.location
  administrator_login    = "cjay"
  administrator_password = random_password.mysql_password.result
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.db-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.db-pvt-dns-zone.id
  sku_name               = "B_Standard_B1ms"
  version = 5.7
  public_network_access = "Disabled"
  storage {
    size_gb = 20
  }
  
  depends_on = [ azurerm_private_dns_zone.db-pvt-dns-zone ]
}

resource "azurerm_mysql_flexible_database" "user-management-mysql-db" {
  name                = "ecomdb"
  resource_group_name = data.azurerm_resource_group.user-management.name
  server_name         = azurerm_mysql_flexible_server.user-management-mysql-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}