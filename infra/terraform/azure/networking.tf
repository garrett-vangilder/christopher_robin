resource "azurerm_network_interface" "nic" {
  count = var.server_count
  name                      = "flask-server-nic-${count.index}"
  location                  = azurerm_resource_group.rg.location    
  resource_group_name       = azurerm_resource_group.rg.name

  ip_configuration {
    name                    = "internal"
    subnet_id               = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub_addr[count.index].id
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                      = "flask-server-vnet"
  resource_group_name       = azurerm_resource_group.rg.name
  address_space             = ["10.0.0.0/16"]
    location                  = "eastus"
}

resource "azurerm_subnet" "subnet" {
  name                      = "flask-server-subnet"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  address_prefixes          = ["10.0.1.0/24"]
}
