variable "environment" {
    description = "environment name"
    type = string 
}

variable "vpc_id" {
    description = "vpc id where security group will be created"
    type = string
}

variable "app_port" {
    description = "port that app load balencer will listens"
    type = number
    default = 80
}

variable "db_port" {
    description = "port that database will listen"
    type = number 
    default = 5432
}