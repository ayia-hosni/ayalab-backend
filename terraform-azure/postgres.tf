resource "azurerm_postgresql_flexible_server" "main" {
  name                = "ayalab-postgres"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  version  = "16"
  zone     = "1"
  sku_name = "B_Standard_B1ms" # burstable, cheapest tier

  storage_mb = 32768 # minimum allowed

  administrator_login    = "ayalab"
  administrator_password = var.db_password

  delegated_subnet_id = azurerm_subnet.db.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "ayalab"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
