variable "ingress_port" {
  default = 5432
}

variable "egress_port" {
  default = 0
}

variable "cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "db_secret_name" {
  description = "Name for the database secret in Secrets Manager"
  type        = string
  default     = "api_postgres_secret"
}

variable "db_instance" {
  description = "configuration for dbs"
  type = object({
    identifier          = string
    engine              = string
    instance_class      = string
    allocated_storage   = number
    username            = string
    passsword           = string
    db_name             = string
    publicly_accessible = bool
    skip_final_snapshot = bool
  })
  default = {
    identifier          = "api-postgres-db"
    engine              = "postgres"
    instance_class      = "db.t3.micro"
    allocated_storage   = 20
    username            = "admin_main"
    passsword           = "password123" # Use a random password in real setup
    db_name             = "apidb"
    publicly_accessible = true
    skip_final_snapshot = true
  }
}
