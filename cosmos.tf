resource "azurerm_cosmosdb_account" "this" {
  name                = "${var.prefix}-cosmosdb-account"
  offer_type          = "Standard"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location


  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "this" {
  name                = "terraform-plan-storage"
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
}

resource "azurerm_cosmosdb_sql_container" "this" {
  name                = "terraform-plan-storage"
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name

  partition_key_path = "/id"
}


resource "azurerm_role_assignment" "account" {
  scope                = azurerm_cosmosdb_account.this.id
  role_definition_name = "DocumentDB Account Contributor"
  principal_id         = azuread_service_principal.github_oidc.id
}

resource "azurerm_role_assignment" "operator" {
  scope                = azurerm_cosmosdb_account.this.id
  role_definition_name = "Cosmos DB Operator"
  principal_id         = azuread_service_principal.github_oidc.id
}

# https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#built-in-role-definitions
# Cosmos DB Built-in Data Contributor
data "azurerm_cosmosdb_sql_role_definition" "this" {
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  role_definition_id  = "00000000-0000-0000-0000-000000000002"
}

resource "azurerm_cosmosdb_sql_role_assignment" "example" {
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.this.id
  principal_id        = azuread_service_principal.github_oidc.id
  scope               = azurerm_cosmosdb_account.this.id
}
