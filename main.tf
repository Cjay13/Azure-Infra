terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.31.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "~> 2.17.0"
    }
  }

  backend "azurerm" {
    resource_group_name = "test_group"
    storage_account_name = "cjayteststorageacct"
    container_name = "terraform-state-bucket"
    key = "azure-infra/terraform.tfstate"

    
  }
}

provider "azurerm" {

    features {
      
    }

    use_msi = true
    subscription_id = "26036c57-ce1e-40f4-aa1d-e550302a08e6"
    skip_provider_registration = true
}


provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.user-management-aks.kube_config[0].host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.user-management-aks.kube_config[0].cluster_ca_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.user-management-aks.kube_config[0].client_key)
    client_certificate = base64decode(azurerm_kubernetes_cluster.user-management-aks.kube_config[0].client_certificate)
  }
}