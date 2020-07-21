##############################################################################
# * HashiCorp Beginner's Guide to Using Terraform on Azure
# 
# This Terraform configuration will create the following:

##############################################################################
#Specify cloud provider: Azure
provider "azurerm" {
   features {}
}
##############################################################################
#Dev RG Resources
#####################

#Resource Group
resource "azurerm_resource_group" "example" {
  name     = "${var.resource_group_dev}"
  location = "${var.location}"
  }

#Storage Account
resource "azurerm_storage_account" "dev" {
  name                     = "etlfunctionsdevelopment"
  resource_group_name      = azurerm_resource_group.dev.name
  location                 = azurerm_resource_group.dev.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
}

#App Service Plan
resource "azurerm_app_service_plan" "dev" {
  name                = "etlfunctions-ASP-development"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  kind                = "Linux"
  reserved             = true
  sku {
    tier = "Free"
    size = "F1"
  }
}

#Function App
resource "azurerm_function_app" "dev" {
  name                      = "etlfunctions-development-azurefunctions"
  location                  = azurerm_resource_group.dev.location
  resource_group_name       = azurerm_resource_group.dev.name
  app_service_plan_id       = azurerm_app_service_plan.dev.id
  storage_connection_string = azurerm_storage_account.dev.primary_connection_string
  version = "~2"

  app_settings = {
        FUNCTIONS_WORKER_RUNTIME = "python"
        FUNCTION_APP_EDIT_MODE = "readonly"
        WEBSITE_PYTHON_DEFAULT_VERSION = "~3.7"
        #WEBSITE_RUN_FROM_PACKAGE = "https://github.com/JoeMark17/Azure-Terraform-Functions.git"
    }
}

#PostgreSQL Dev Server
resource "azurerm_postgresql_server" "dev" {
  name                = "etlfunctions-development-postgresdb"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

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

#PostgreSQL Dev Firewall
resource "azurerm_postgresql_firewall_rule" "dev" {
  name                = "development"
  resource_group_name = azurerm_resource_group.dev.name
  server_name         = azurerm_postgresql_server.dev.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

#PostgreSQL Dev Database
resource "azurerm_postgresql_database" "dev" {
  name                = "AdventureWorksDWH"
  resource_group_name = azurerm_resource_group.dev.name
  server_name         = azurerm_postgresql_server.dev.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

#PostreSQL Source Server
resource "azurerm_postgresql_server" "dev2" {
  name                = "etlfunctions-adventureworks-postgresdb"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

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

#PostreSQL Source Firewall
resource "azurerm_postgresql_firewall_rule" "dev2" {
  name                = "source"
  resource_group_name = azurerm_resource_group.dev.name
  server_name         = azurerm_postgresql_server.dev2.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

#PostreSQL Source Database
resource "azurerm_postgresql_database" "dev2" {
  name                = "AdventureWorks"
  resource_group_name = azurerm_resource_group.dev.name
  server_name         = azurerm_postgresql_server.dev2.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

#Azure Data Factory
resource "azurerm_data_factory" "dev" {
  name                = "etlfunctions-development-adf"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

  github_configuration{

    account_name      = "JoeMark17"
    branch_name       = "master"
    git_url           = "https://github.com"
    repository_name   = "AzureDataFactory-etlfunctions"
    root_folder       = "/"
  }

}

##############################################################################
#Prod RG Resources
#####################

#Resource Group
resource "azurerm_resource_group" "prod" {
  name     = "${var.resource_group_prod}"
  location = "${var.location}"
  }

#Storage Account
resource "azurerm_storage_account" "prod" {
  name                     = "etlfunctionsproduction"
  resource_group_name      = azurerm_resource_group.prod.name
  location                 = azurerm_resource_group.prod.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"
}

#App Service Plan
resource "azurerm_app_service_plan" "prod" {
  name                = "etlfunctions-ASP-production"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  kind                = "Linux"
  reserved             = true
  sku {
    tier = "Free"
    size = "F1"
  }
}

#Function App
resource "azurerm_function_app" "prod" {
  name                      = "etlfunctions-production-azurefunctions"
  location                  = azurerm_resource_group.prod.location
  resource_group_name       = azurerm_resource_group.prod.name
  app_service_plan_id       = azurerm_app_service_plan.prod.id
  storage_connection_string = azurerm_storage_account.prod.primary_connection_string
  version = "~2"

  app_settings = {
        FUNCTIONS_WORKER_RUNTIME = "python"
        FUNCTION_APP_EDIT_MODE = "readonly"
        WEBSITE_PYTHON_DEFAULT_VERSION = "~3.7"
        #WEBSITE_RUN_FROM_PACKAGE = "https://github.com/JoeMark17/Azure-Terraform-Functions.git"
    }
}

#PostgreSQL Prod Server
resource "azurerm_postgresql_server" "prod" {
  name                = "etlfunctions-production-postgresdb"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name

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

#PostgreSQL Prod Firewall
resource "azurerm_postgresql_firewall_rule" "prod" {
  name                = "production"
  resource_group_name = azurerm_resource_group.prod.name
  server_name         = azurerm_postgresql_server.prod.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

#PostgreSQL Prod Database
resource "azurerm_postgresql_database" "prod" {
  name                = "AdventureWorksDWH"
  resource_group_name = azurerm_resource_group.prod.name
  server_name         = azurerm_postgresql_server.prod.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

#Azure Data Factory
resource "azurerm_data_factory" "prod" {
  name                = "etlfunctions-production-adf"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
}

