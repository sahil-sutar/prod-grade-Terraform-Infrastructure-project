output "alb_public_url" {
  description = "Public URL to access the application"
  value       = "http://${module.compute.alb_dns_name}"
}

output "database_endpoint" {
  description = "RDS Database endpoint"
  value       = module.database.db_endpoint
}