resource "azurerm_virtual_network" "demovnet1" {
  name  = "demovnet-1"
  address_space = ["172.0.0.0/17"]
  location = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_network_security_group" "demosecuritygroup1" {
   name = "netsecurity-group"
   location = var.location
   resource_group_name = var.rg_name
   
   security_rule {
     name   = "allow only SSH"
     priority = 100
     direction = "inbound"
     access = "allow"
     protocol = "tcp"
     source_port_range = "22"
     destination_port_range = "*"
     source_address_prefix = "0.0.0.0/0"
     destination_address_prefix = "VirtualNetwork"
    }
}


resource "azurerm_subnet" "demosubnet1" {
  name = "demo-subnet1"
  address_prefixes = ["172.0.1.0/24"]
  resource_group_name = var.rg_name
  virtual_network_name = azurerm_virtual_network.demovnet1.name 
}

resource "azurerm_subnet_network_security_group_association" "subnetnetworksecuritydemo" {
  subnet_id                 = azurerm_subnet.demosubnet1.id
  network_security_group_id = azurerm_network_security_group.demosecuritygroup1.id
}


resource "azurerm_public_ip" "public1demo" {
   name = "public-1demo"
   location = var.location
   resource_group_name = var.rg_name
   allocation_method = "Dynamic"
}
   

resource "azurerm_network_interface" "demointerface1" {
   name = "inc1"
   location = var.location
   resource_group_name = var.rg_name

   ip_configuration {
    name = azurerm_subnet.demosubnet1.name
    subnet_id =  azurerm_subnet.demosubnet1.id
    private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface_security_group_association" "networkinterfacedemo1" {
  network_interface_id      = azurerm_network_interface.demointerface1.id
  network_security_group_id = azurerm_network_security_group.demosecuritygroup1.id
}

resource "azurerm_windows_virtual_machine" "demo-vm" {
   name = var.vm_name
   location = var.location
   resource_group_name = var.rg_name
   computer_name = "windows"
   encryption_at_host_enabled = true
   enable_automatic_updates = true
   size                = "Standard_F2"
   admin_username      = "user1"
   admin_password      = "Divyauser@1234"
   network_interface_ids = [azurerm_network_interface.demointerface1.id]
   #public_ip_address = azurerm_public_ip.public1demo.id

os_disk {
  caching = "ReadWrite"
  storage_account_type = "Standard_LRS"
}

source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
   }
}




   
  
