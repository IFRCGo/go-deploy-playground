variable "app_name" {
  type = string
}

variable "pull_principal_ids" {
  type    = list(any)
  default = []
}

variable "environment" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every taggable resource"
}
