resource "azurerm_storage_account" "state" {
  name                     = "${lower(replace(var.prefix, "-", ""))}tfstate"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "storage_container" {
  scope                = azurerm_storage_container.state.resource_manager_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.github_oidc.id
}

resource "azurerm_storage_account" "planstorage" {
  name                     = "${lower(replace(var.prefix, "-", ""))}plans"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "planstorage" {
  name                  = "resources"
  storage_account_name  = azurerm_storage_account.planstorage.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "planstorage_container" {
  scope                = azurerm_storage_container.planstorage.resource_manager_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.github_oidc.id
}
