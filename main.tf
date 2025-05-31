terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.31.0"
    }
  }
}

provider "azurerm" {

    features {
      
    }

    use_msi = true
    subscription_id = "26036c57-ce1e-40f4-aa1d-e550302a08e6"
}