resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm"  
  location              = azurerm_resource_group.tier_app.location
  resource_group_name   = azurerm_resource_group.tier_app.name
  network_interface_ids = [azurerm_network_interface.myvm1nic.id]
  size                  = "Standard_DS1_v2"
  admin_username        = var.admin_user
  admin_password        = var.admin_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
    depends_on = [
    azurerm_network_interface.myvm1nic
  ]
   
}