output "api_gateway_rest_api" {
  value       = aws_api_gateway_rest_api.api
  description = "The Rest API Gateway that was created"
}

output "iam_role_arn" {
  value       = aws_iam_role.api_gateway_role.arn
  description = "The IAM Role ARN for the API Gateway"
}

output "iam_role_name" {
  value       = aws_iam_role.api_gateway_role.name
  description = "The IAM Role Name for the API Gateway"
}