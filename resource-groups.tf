resource "azurerm_resource_group" "state" {
  name     = "${var.prefix}-state"
  location = var.location
}

resource "azurerm_resource_group" "identity" {
  name     = "${var.prefix}-identity"
  location = var.location
}

resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-resources"
  location = var.location
}
