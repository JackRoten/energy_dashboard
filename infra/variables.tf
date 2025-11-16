variable "region" {
  description = "Region of AWS services"
  type        = string
  sensitive   = true
}

# variable "api_lambda_arn" {
#   description = "API gateway ARN"
#   type        = string
# }

# variable "api_gateway_arn" {
#   description = "API gateway ARN"
#   type        = string
# }

# Variable to hold your secret (never hardcode the key!)
variable "eia_api_key" {
  description = "EIA API key for accessing electricity data"
  type        = string
  sensitive   = true
}

variable "cidr_blocks" {
  description = "IP Addresses Allocation"
  type        = list(string)
}

variable "egress_port" {
  description = "Egress port for security group"
  type        = number
}

variable "ingress_port" {
  description = "Ingress port for security group"
  type        = number
}

variable "db_secret_name" {
  description = "Secret name for db instance"
  type        = string

}

variable "db_instance" {
  description = "Configuration for RDS database instance"
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
