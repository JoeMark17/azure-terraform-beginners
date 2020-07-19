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
  name                = "azure-functions-test-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "example" {
  name                       = "terraform-test-azure-functions"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  os_type                    = "linux"
  version                    = "~2"
    app_settings = {
        https_only = true
        FUNCTIONS_WORKER_RUNTIME = "Python"
        WEBSITE_NODE_DEFAULT_VERSION = "~3.7"
        FUNCTION_APP_EDIT_MODE = "readonly"
    }
}
