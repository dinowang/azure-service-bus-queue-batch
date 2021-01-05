provider "azurerm" {
  features {
  }
}

resource "random_id" "code" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
  }

  byte_length = 4
}

variable "code" {
  default = "sbtest"
}

resource "azurerm_resource_group" "default" {
  name     = "${var.code}-${random_id.code.hex}-rg"
  location = "southeastasia"
}

resource "azurerm_servicebus_namespace" "default" {
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  name                = "${var.code}-${random_id.code.hex}-ns"
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "default" {
  resource_group_name = azurerm_resource_group.default.name
  namespace_name      = azurerm_servicebus_namespace.default.name
  name                = "messages"
  enable_partitioning = true
}

resource "azurerm_servicebus_namespace_authorization_rule" "sample" {
  resource_group_name = azurerm_resource_group.default.name
  namespace_name      = azurerm_servicebus_namespace.default.name
  name                = "sample"
  listen              = true
  send                = true
  manage              = false
}

resource "azurerm_storage_account" "default" {
  location                 = azurerm_resource_group.default.location
  resource_group_name      = azurerm_resource_group.default.name
  name                     = "${var.code}${random_id.code.hex}stor"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "default" {
  name                = "${var.code}-${random_id.code.hex}-ai"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "default" {
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  name                = "${var.code}-${random_id.code.hex}-plan"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "default" {
  location                   = azurerm_resource_group.default.location
  resource_group_name        = azurerm_resource_group.default.name
  app_service_plan_id        = azurerm_app_service_plan.default.id
  name                       = "${var.code}-${random_id.code.hex}-func"
  version                    = "~3"
  storage_account_name       = azurerm_storage_account.default.name
  storage_account_access_key = azurerm_storage_account.default.primary_access_key

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.default.instrumentation_key
    ServiceBusConnection           = azurerm_servicebus_namespace_authorization_rule.sample.primary_connection_string
  }
}
