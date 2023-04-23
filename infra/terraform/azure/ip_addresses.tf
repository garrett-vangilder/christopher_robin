resource "azurerm_public_ip" "pub_addr" {
  count = var.server_count    
  name                = "pip-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Dynamic"
}