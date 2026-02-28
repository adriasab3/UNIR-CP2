resource "azurerm_network_security_group" "security_group" {
  name                = "example-security-group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  security_rule {
	name				= "inbound"
	priority			= 100
	direction			= "Inbound"
	access				= "Allow"
	protocol			= "Tcp"
	source_port_range		= "*"
 	destination_port_range     	= "*"
 	source_address_prefix      	= "*"
	destination_address_prefix 	= "*"
  }
  security_rule {
        name                            = "outbound"
        priority                        = 100
        direction                       = "Outbound"
        access                          = "Allow"
        protocol                        = "Tcp"
        source_port_range               = "*"
        destination_port_range          = "*"
        source_address_prefix           = "*"
        destination_address_prefix      = "*"
  }
}


resource "azurerm_virtual_network" "network" {
  name                = "example-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
#  dns_servers         = ["10.0.0.4", "10.0.0.5"]

#  subnet {
#    name             = "subnet1"
#    address_prefix   = "10.0.1.0/24"
#    security_group   = azurerm_network_security_group.security_group.id
#  }

  tags = {
    environment = "casopractico2"
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.security_group.id
}

resource "azurerm_public_ip" "public_ip" {
	name                = "public_ip_vm"
	resource_group_name = azurerm_resource_group.rg.name
	location            = azurerm_resource_group.rg.location
	allocation_method   = "Static"
	sku		    = "Standard"
}

resource "azurerm_network_interface" "interface" {
  name                = "interface"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id	  = azurerm_public_ip.public_ip.id
  }
}



resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-CP2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ats_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.interface.id,
  ]
  admin_ssh_key {
#    username   = "adminuser"
    username   = var.ssh_user
#    public_key = file("./UNIR.pub")
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


