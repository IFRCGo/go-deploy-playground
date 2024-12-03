variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "github_org" {
  type        = string
  description = "GitHub organization name"
  default     = "IFRCGo"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}