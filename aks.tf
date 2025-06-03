resource "azurerm_kubernetes_cluster" "user-management-aks" {
  name                = "user-management-aks"
  location            = data.azurerm_resource_group.user-management.location
  resource_group_name = data.azurerm_resource_group.user-management.name
  dns_prefix          = "usermgtaks"
  private_cluster_enabled = true

  default_node_pool {
    name       = "default"
    auto_scaling_enabled = true
    node_count = 2
    max_count = 5
    min_count = 2
    vm_size    = "Standard_D2ds_v5"
    vnet_subnet_id = azurerm_subnet.aks-subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled = true

  tags = {
    project = "user-management"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.user-management-appgw.id
  }
}


resource "azurerm_role_assignment" "agic_reader" {
  scope                = data.azurerm_resource_group.user-management.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.user-management-aks.identity[0].principal_id
}

resource "azurerm_role_assignment" "agic_contributor" {
  scope                = azurerm_application_gateway.user-management-appgw.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.user-management-aks.identity[0].principal_id
}

resource "azurerm_user_assigned_identity" "aks-vault-user" {
  location            = data.azurerm_resource_group.user-management.location
  name                = "aks-vault-user"
  resource_group_name = data.azurerm_resource_group.user-management.name
}

resource "azurerm_role_assignment" "aks-valut-user-role" {
  scope                = data.azurerm_key_vault.cjaydevops-key-vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aks-valut-user.principal_id
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.user-management-aks.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.user-management-aks.kube_config_raw
  sensitive = true
}

output "aks-vault-user-principal_id" {
  value = azurerm_user_assigned_identity.aks-valut-user.principal_id
}

output "aks-vault-user-client_id" {
  value = azurerm_user_assigned_identity.aks-valut-user.client_id
}