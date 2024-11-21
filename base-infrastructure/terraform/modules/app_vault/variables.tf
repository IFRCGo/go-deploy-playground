variable "app_name" {
  type = string
}

variable "cluster_namespace" {
  type = string
}

variable "cluster_oidc_issuer_url" {
  type = string 
}

variable "environment" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "secrets" {
  type = map(string)
  default = {}
}

variable "service_account_name" {
  type = string 
  default = "service-token-reader"
}