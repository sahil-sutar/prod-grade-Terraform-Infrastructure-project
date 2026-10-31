
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Controls incoming public traffic to the Application Load Balancer"
  vpc_id      = var.vpc_id

  
  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "Allow outbound to app instances"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}


resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Restricts traffic strictly to the ALB security group"
  vpc_id      = var.vpc_id


  ingress {
    description     = "Allow app traffic strictly from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

 
  egress {
    description = "Allow all outbound traffic via NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-app-sg"
    Environment = var.environment
  }
}


resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Restricts database access strictly to the application instances"
  vpc_id      = var.vpc_id

 
  ingress {
    description     = "Allow database connection only from app servers"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  
  egress {
    description = "No outbound traffic needed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  }
}