#valores que se guardaran al ejecutar terraform apply
output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}
output "ssh_private_key" {
  value = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}
