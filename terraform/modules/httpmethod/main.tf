resource "aws_api_gateway_method" "this" {
  rest_api_id   = var.apigw_id
  resource_id   = var.apigw_resource_id
  http_method   = var.http_method
  authorization = var.authorization
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = var.apigw_id
  resource_id             = var.apigw_resource_id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
}

resource "aws_api_gateway_method_response" "this" {
  rest_api_id = var.apigw_id
  resource_id = var.apigw_resource_id
  http_method = aws_api_gateway_method.this.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.this
  ]
}
