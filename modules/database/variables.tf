variable "environment" {
  description = "Environment name (e.g., prod, dev)"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "List of private DB subnet IDs"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Max allocated storage for autoscaling in GB"
  type        = number
  default     = 50
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Name of the default database to create"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for database"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
}