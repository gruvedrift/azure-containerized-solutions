# output.tf - Outputs values for the Container Apps infrastructure
output "acr_login_server" {
  description = "Login server URL for the container registry"
  value       = azurerm_container_registry.tiny-flask.login_server
}

output "acr_name" {
  description = "Name of the container registry"
  value       = azurerm_container_registry.tiny-flask.name
}
output "container_app_url" {
  description = "The URL of the Container App"
  value       = "https://${azurerm_container_app.tiny-flask.ingress[0].fqdn}"
}