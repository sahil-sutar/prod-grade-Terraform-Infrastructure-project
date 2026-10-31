output "db_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.main.endpoint
}

output "db_address" {
  description = "The hostname of the database instance"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "The port the database is listening on"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}