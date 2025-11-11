variable "region" {
  default = "us-west-2"
}

# Variable to hold your secret (never hardcode the key!)
variable "eia_api_key" {
  description = "EIA API key for accessing electricity data"
  type        = string
  sensitive   = true
}