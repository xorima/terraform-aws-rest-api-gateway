resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_gateway_name
  description = "API Gateway for ${var.api_gateway_name}"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = local.tags
}

resource "aws_api_gateway_resource" "healthz" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "healthz"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "readiness" {
  parent_id   = aws_api_gateway_resource.healthz.id
  path_part   = "readiness"
  rest_api_id = aws_api_gateway_rest_api.api.id
}


resource "aws_api_gateway_method" "readiness" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.readiness.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "readiness" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.readiness.id
  http_method = aws_api_gateway_method.readiness.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
        status     = "ok"
      }
    )
  }
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "readiness_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.readiness.id
  http_method = aws_api_gateway_method.readiness.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "readiness" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.readiness.id
  http_method = aws_api_gateway_method.readiness.http_method
  status_code = aws_api_gateway_method_response.readiness_200.status_code

  response_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
        status     = "ok"
      }
    )
  }
}

data "aws_iam_policy_document" "api_gateway_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["${aws_api_gateway_rest_api.api.execution_arn}/*"]
    }
  }
}

resource "aws_iam_role" "api_gateway_role" {
  name               = "ApiGatewayRole-${var.api_gateway_name}"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
}
