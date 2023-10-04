
resource "azurerm_postgresql_flexible_server" "default" {
  name                   = "app-database-server"
  resource_group_name    = azurerm_resource_group.tier_app.name
  location               = azurerm_resource_group.tier_app.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.subnet-3.id
  private_dns_zone_id    =  azurerm_private_dns_zone.default.id
  administrator_login    = "adminTerraform"
  administrator_password = var.database_admin_password
  zone                   = "3"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D4s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.link]
}