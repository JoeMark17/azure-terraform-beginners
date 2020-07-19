##############################################################################
# * HashiCorp Beginner's Guide to Using Terraform on Azure
# 
# This Terraform configuration will create the following:
#
# Resource group with a virtual network and subnet
# An Ubuntu Linux server running Apache

##############################################################################
# * Shared infrastructure resources
provider "azurerm" {
   features {}
}
# First we'll create a resource group. In Azure every resource belongs to a 
# resource group. Think of it as a container to hold all your resources. 
# You can find a complete list of Azure resources supported by Terraform here:
# https://www.terraform.io/docs/providers/azurerm/
resource "azurerm_resource_group" "example" {
  name     = "${var.resource_group}"
  location = "${var.location}"
  }

resource "azurerm_storage_account" "example" {
  name                     = "terraformstoragetestjoe1"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
}

resource "azurerm_app_service_plan" "example" {
  name                = "terraformest-appserviceplan-pro"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"
  reserved             = true
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "example" {
  name                      = "terraform-test-azure-functions"
  location                  = azurerm_resource_group.example.location
  resource_group_name       = azurerm_resource_group.example.name
  app_service_plan_id       = azurerm_app_service_plan.example.id
  storage_connection_string = azurerm_storage_account.example.primary_connection_string
  version = "~2"

  app_settings = {
        FUNCTIONS_WORKER_RUNTIME = "python"
        FUNCTION_APP_EDIT_MODE = "readonly"
        WEBSITE_PYTHON_DEFAULT_VERSION = "~3.7"
    }
}
