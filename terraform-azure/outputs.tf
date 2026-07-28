output "backend_url" {
  description = "Public URL of the backend API"
  value       = "http://${azurerm_public_ip.backend.ip_address}:8080"
}

output "vm_public_ip" {
  description = "Public IP of the VM"
  value       = azurerm_public_ip.backend.ip_address
}

output "postgres_fqdn" {
  description = "PostgreSQL Flexible Server FQDN (private, reachable only from within the VNet)"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "ssh_command" {
  description = "Command to SSH into the VM"
  value       = "ssh -i ${var.ssh_private_key_path} ${var.admin_username}@${azurerm_public_ip.backend.ip_address}"
}
