resource "aws_api_gateway_resource" "this" {
  rest_api_id = var.apigw_id
  parent_id   = var.apigw_resource_id
  path_part   = var.path
}

# OPTIONS method
resource "aws_api_gateway_method" "options" {
  rest_api_id   = var.apigw_id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method response
resource "aws_api_gateway_method_response" "options" {
  rest_api_id = var.apigw_id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [ aws_api_gateway_method.options ]
}

# OPTIONS integration
resource "aws_api_gateway_integration" "options" {
  rest_api_id = var.apigw_id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.options.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  depends_on = [ aws_api_gateway_method.options ]
}

# OPTIONS integration response

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = var.apigw_id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code
  response_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [ aws_api_gateway_method_response.options ]
}

