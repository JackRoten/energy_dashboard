variable "ingress_port" {
  type = number
}

variable "egress_port" {
  type = number
}

variable "cidr_blocks" {
  description = "IP Addresses Allocation"
  type = list
}

variable "db_secret_name" {
  description = "Name for the database secret in Secrets Manager"
  type        = string
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
}
