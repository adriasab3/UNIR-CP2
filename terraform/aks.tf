resource "azurerm_kubernetes_cluster" "aks1" {
  name                = "aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "exampleaks1"
  sku_tier	      = "Standard"
  role_based_access_control_enabled = true
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B4ls_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "casopractico2"
  }
}

resource "azurerm_role_assignment" "ra-perm" {
	principal_id = azurerm_kubernetes_cluster.aks1.identity[0].principal_id
	role_definition_name = "AcrPull"
	scope = azurerm_container_registry.acr.id
}
