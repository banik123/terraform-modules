data "azurerm_subscription" "current" {
}

output "current_subscription_display_name" {
  value = data.azurerm_subscription.current.display_name
}
resource "azurerm_resource_group" "tier_app" {
  name     = "tier_app"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vpc" {
  name                = "app-vnet"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.tier_app.location
  resource_group_name = azurerm_resource_group.tier_app.name
  depends_on = [
    azurerm_resource_group.tier_app
  ]
}

resource "azurerm_subnet" "subnet-1" {
  name                 = "subnet-1"
  resource_group_name  = azurerm_resource_group.tier_app.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = ["10.1.0.0/16"]

}
resource "azurerm_subnet" "subnet-2" {
  name                 = "subnet-2"
  resource_group_name  = azurerm_resource_group.tier_app.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = ["10.2.0.0/16"]
}
resource "azurerm_subnet" "subnet-3" {
  name                 = "subnet-3"
  resource_group_name  = azurerm_resource_group.tier_app.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = ["10.3.0.0/16"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.subnet-3.id
  network_security_group_id = azurerm_network_security_group.database.id
}

resource "azurerm_private_dns_zone" "default" {
  name                = "app-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.tier_app.name

  depends_on = [azurerm_subnet_network_security_group_association.default]
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "app-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.vpc.id
  resource_group_name   = azurerm_resource_group.tier_app.name
}

resource "azurerm_public_ip" "myvm1publicip" {
  name = "publicip1"
  location = azurerm_resource_group.tier_app.location
  resource_group_name = azurerm_resource_group.tier_app.name
  allocation_method = "Dynamic"
  sku = "Basic"
  depends_on = [
    azurerm_resource_group.tier_app,

  ]
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.tier_app.location
  resource_group_name = azurerm_resource_group.tier_app.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_security_group" "database" {
  name                = "database-nsg"
  location            = azurerm_resource_group.tier_app.location
  resource_group_name = azurerm_resource_group.tier_app.name

  security_rule {
    name                       = "test"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "myvm1nic" {
  name = "myvm1-nic"
  location = azurerm_resource_group.tier_app.location
  resource_group_name = azurerm_resource_group.tier_app.name
  

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.myvm1publicip.id
  }
    depends_on = [
    azurerm_public_ip.myvm1publicip,
    azurerm_virtual_network.vpc
  ]
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.myvm1nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}



