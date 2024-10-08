resource "aws_api_gateway_rest_api" "this" {
  name = var.app_name
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "this" {
  name                   = "${var.app_name}-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.this.id
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [aws_cognito_user_pool.this.arn]
  identity_source        = "method.request.header.Authorization"
}

# Create path hello
module "path_hello" {
  source = "./modules/pathresource"
  apigw_id = aws_api_gateway_rest_api.this.id
  apigw_resource_id = aws_api_gateway_rest_api.this.root_resource_id
  path = "hello"
}

module "hello1" {
  source = "./modules/httpmethod"
  apigw_id = aws_api_gateway_rest_api.this.id
  apigw_resource_id = module.path_hello.id
  http_method = "POST"
  lambda_arn = aws_lambda_function.lambda_hello1.invoke_arn
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

# Create path events
module "path_events" {
  source = "./modules/pathresource"
  apigw_id = aws_api_gateway_rest_api.this.id
  apigw_resource_id = aws_api_gateway_rest_api.this.root_resource_id
  path = "events"
}

# Create event resource
module "create_event" {
  source = "./modules/httpmethod"
  apigw_id = aws_api_gateway_rest_api.this.id
  apigw_resource_id = module.path_events.id
  http_method = "POST"
  lambda_arn = aws_lambda_function.lambda_eventAdmin.invoke_arn
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

module "get_events" {
  source = "./modules/httpmethod"
  apigw_id = aws_api_gateway_rest_api.this.id
  apigw_resource_id = module.path_events.id
  http_method = "GET"
  lambda_arn = aws_lambda_function.lambda_eventUser.invoke_arn
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_lambda_permission" "hello1" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_hello1.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${replace(aws_api_gateway_deployment.this.execution_arn, var.stage_name, "")}*/*"
}

resource "aws_lambda_permission" "create_event" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_eventAdmin.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${replace(aws_api_gateway_deployment.this.execution_arn, var.stage_name, "")}*/*"
}

resource "aws_lambda_permission" "get_events" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_eventUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${replace(aws_api_gateway_deployment.this.execution_arn, var.stage_name, "")}*/*"
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = md5(file("apigateway.tf"))
    #Redeploy every time
    #redeployment = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    module.create_event,
    module.get_events,
    module.hello1
  ]
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    logging_level = "INFO"
    data_trace_enabled = true
    metrics_enabled = true
  }

  depends_on = [
    aws_api_gateway_deployment.this
  ]
}

resource "aws_api_gateway_stage" "this" {
  stage_name    = var.stage_name
  rest_api_id   = aws_api_gateway_deployment.this.rest_api_id
  deployment_id = aws_api_gateway_deployment.this.id
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.this.id}/${var.stage_name}"
  retention_in_days = 1
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name              = "${var.api_subdomain}.${var.domain_name}"
  regional_certificate_arn = var.certificate_arn
  security_policy          = "TLS_1_2"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = aws_api_gateway_rest_api.this.id
  domain_name = aws_api_gateway_domain_name.this.domain_name
  stage_name  = aws_api_gateway_stage.this.stage_name
}
