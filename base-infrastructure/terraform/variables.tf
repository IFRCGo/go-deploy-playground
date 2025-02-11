variable "environment" {
  type        = string
  default     = "playground"
  description = "defines the environment to deploy to"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "defines the location to deploy to"
}

variable "psql_administrator_login" {
  type    = string
  default = "psqladmin"
}