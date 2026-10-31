
resource "aws_db_subnet_group" "main" {
  name        = "${var.environment}-db-subnet-group"
  description = "Subnet group for RDS database instance"
  subnet_ids  = var.private_db_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}


resource "aws_db_instance" "main" {
  identifier        = "${var.environment}-db"
  allocated_storage = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]

  # सुरक्षेसाठी अत्यंत महत्त्वाच्या सेटिंग्स
  publicly_accessible = false
  storage_encrypted   = true
  skip_final_snapshot = true 


  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  tags = {
    Name        = "${var.environment}-db"
    Environment = var.environment
  }
}