resource "random_password" "mysql_password" {
  length  = 16
  special = true
  override_special = "!@#"
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
  sku_name               = "GP_Standard_D2ds_v4"
  version = 5.7
  public_network_access = "Disabled"
  high_availability {
    mode = "Disabled"
  }
  storage {
    size_gb = 20
  }
  
}

resource "azurerm_mysql_flexible_database" "user-management-mysql-db" {
  name                = "ecomdb"
  resource_group_name = data.azurerm_resource_group.user-management.name
  server_name         = azurerm_mysql_flexible_server.user-management-mysql-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}