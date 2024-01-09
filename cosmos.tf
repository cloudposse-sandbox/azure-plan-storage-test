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
  database_name = azurerm_cosmosdb_sql_database.this.name

  partition_key_path = "/id"
}
