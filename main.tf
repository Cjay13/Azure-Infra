terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.31.0"
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