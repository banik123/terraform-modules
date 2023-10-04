resource "azurerm_kubernetes_cluster_node_pool" "worker" {
  zones = [3]
  enable_auto_scaling   = true
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  max_count             = 5
  min_count             = 3
  mode                  = "User"
  name                  = "backendpool"
  orchestrator_version  = "1.26.3"
  os_disk_size_gb       = 30
  os_type               = "Linux"
  vm_size               = "Standard_D4s_v3"
  priority              = "Regular"
  vnet_subnet_id        = azurerm_subnet.subnet-2.id 
  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "nodepoolos"    = "linux"
    "app"           = "java-apps"
  }
  tags = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "nodepoolos"    = "linux"
    "app"           = "java-apps"
  }
}