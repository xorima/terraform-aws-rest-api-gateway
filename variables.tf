variable "api_gateway_name" {
  type        = string
  description = "Name of the API Gateway"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resources generated by this module"
  default     = {}
}

locals {
  tags = merge(var.tags, {
    "Name"   = var.api_gateway_name
    "Source" = "Terraform"
    "Module" = "rest-api-gateway"
  })
}