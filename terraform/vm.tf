#definición del security group para la vm, habilitando las conexiones hacia sus puertos 22 (ssh) y 80(http) 
resource "azurerm_network_security_group" "security_group" {
  name                = "example-security-group"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  
  security_rule {
	name				= "inbound"
	priority			= 100
	direction			= "Inbound"
	access				= "Allow"
	protocol			= "Tcp"
	source_port_range		= "*"
 	destination_port_range     	= "22"
 	source_address_prefix      	= "*"
	destination_address_prefix 	= "*"
  }
  security_rule {
   	name                       = "allow-http"
    	priority                   = 101
    	direction                  = "Inbound"
    	access                     = "Allow"
    	protocol                   = "Tcp"
    	source_port_range          = "*"
    	destination_port_range     = "80"
    	source_address_prefix      = "*"
    	destination_address_prefix = "*"
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
  tags = {
    environment = "casopractico2"
  }
}

#definición de la red
resource "azurerm_virtual_network" "network" {
  name                = "example-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "casopractico2"
  }
}

#definición de la subred
resource "azurerm_subnet" "subnet1" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.2.0/24"]
}

#asociar la subred con el security group, de modo que todos los puertos creados en la subred apliquen las reglas definidas previamente
resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.security_group.id
}

#definición de la ip pública para la vm
resource "azurerm_public_ip" "public_ip" {
	name                = "public_ip_vm"
	resource_group_name = azurerm_resource_group.rg.name
	location            = var.location
	allocation_method   = "Static"
	sku		    = "Standard"
    tags = {
       environment = "casopractico2"
    }
}

#definición de la interfaz de red
resource "azurerm_network_interface" "interface" {
  name                = "interface"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id	  = azurerm_public_ip.public_ip.id
  }
  tags = {
    environment = "casopractico2"
  }
}

#definición de la clave ssh
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#definición de la vm
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-CP2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B2ats_v2"
  admin_username      = var.ssh_user
  network_interface_ids = [
    azurerm_network_interface.interface.id,
  ]
  #añadir key a la vm
  admin_ssh_key {
    username   = var.ssh_user
    public_key = tls_private_key.ssh_key.public_key_openssh
  }
   
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  #imagen utilizada para la vm
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = {
    environment = "casopractico2"
  }
}


