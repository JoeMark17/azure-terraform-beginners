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
  name                     = "etlfunctionsterraform"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
}

resource "azurerm_app_service_plan" "example" {
  name                = "etlfunctions-ASP-terraform"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"
  reserved             = true
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_function_app" "example" {
  name                      = "etlfunctions-terraform-azurefunctions"
  location                  = azurerm_resource_group.example.location
  resource_group_name       = azurerm_resource_group.example.name
  app_service_plan_id       = azurerm_app_service_plan.example.id
  storage_connection_string = azurerm_storage_account.example.primary_connection_string
  version = "~2"

  app_settings = {
        FUNCTIONS_WORKER_RUNTIME = "python"
        FUNCTION_APP_EDIT_MODE = "readonly"
        WEBSITE_PYTHON_DEFAULT_VERSION = "~3.7"
        WEBSITE_RUN_FROM_PACKAGE = "https://github.com/JoeMark17/Azure-Terraform-Functions.git"
    }
}

resource "azurerm_postgresql_server" "example" {
  name                = "etlfunctions-dev-terraformpg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku_name = "B_Gen5_1"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "pythonframeworkadmin"
  administrator_login_password = "Postgresserver@dmin"
  version                      = "10"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_firewall_rule" "example" {
  name                = "terraform"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
  start_ip_address    = "40.112.8.12"
  end_ip_address      = "40.112.8.12"
}

resource "azurerm_postgresql_database" "example" {
  name                = "AdventureWorksDWH"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_server" "example2" {
  name                = "etlfunctions-source-terraformpg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku_name = "B_Gen5_1"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "pythonframeworkadmin"
  administrator_login_password = "Postgresserver@dmin"
  version                      = "10"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_firewall_rule" "example2" {
  name                = "terraform"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example2.name
  start_ip_address    = "40.112.8.12"
  end_ip_address      = "40.112.8.12"
}

resource "azurerm_postgresql_database" "example2" {
  name                = "AdventureWorks"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example2.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_data_factory" "example" {
  name                = "etlfunctions-terraform-adf"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

}
