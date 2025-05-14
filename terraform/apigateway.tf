resource "aws_api_gateway_rest_api" "this" {
  name = var.app_name
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "this" {
  name            = "${var.app_name}-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.this.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.this.arn]
  identity_source = "method.request.header.Authorization"
}

# Create path hello
module "path_hello" {
  source            = "./modules/pathresource"
  apigw_id          = aws_api_gateway_rest_api.this.id
  apigw_resource_id = aws_api_gateway_rest_api.this.root_resource_id
  path              = "hello"
}

module "hello1" {
  source            = "./modules/httpmethod"
  apigw_id          = aws_api_gateway_rest_api.this.id
  apigw_resource_id = module.path_hello.id
  http_method       = "POST"
  lambda_arn        = aws_lambda_function.lambda_hello1.invoke_arn
  authorization     = "COGNITO_USER_POOLS"
  authorizer_id     = aws_api_gateway_authorizer.this.id
}

# Create path events
module "path_events" {
  source            = "./modules/pathresource"
  apigw_id          = aws_api_gateway_rest_api.this.id
  apigw_resource_id = aws_api_gateway_rest_api.this.root_resource_id
  path              = "events"
}

# Create event resource
module "create_event" {
  source            = "./modules/httpmethod"
  apigw_id          = aws_api_gateway_rest_api.this.id
  apigw_resource_id = module.path_events.id
  http_method       = "POST"
  lambda_arn        = aws_lambda_function.lambda_eventAdmin.invoke_arn
  authorization     = "COGNITO_USER_POOLS"
  authorizer_id     = aws_api_gateway_authorizer.this.id
}

module "get_events" {
  source            = "./modules/httpmethod"
  apigw_id          = aws_api_gateway_rest_api.this.id
  apigw_resource_id = module.path_events.id
  http_method       = "GET"
  lambda_arn        = aws_lambda_function.lambda_eventUser.invoke_arn
  authorization     = "COGNITO_USER_POOLS"
  authorizer_id     = aws_api_gateway_authorizer.this.id
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
    #redeployment = md5(file("apigateway.tf"))
    #Redeploy every time
    redeployment = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    module.create_event,
    module.get_events,
    module.hello1,
    aws_api_gateway_method.create_event
  ]
}

resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }

  depends_on = [
    aws_api_gateway_deployment.this
  ]
}

# Path db

resource "aws_api_gateway_resource" "db" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "db"
}

resource "aws_iam_role" "api_gateway_role" {
  name = "api_gateway_dynamodb_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals" = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.this.id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_policy" {
  name = "api_gateway_dynamodb_policy"
  role = aws_iam_role.api_gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:*"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.eventsV2.arn
        Condition = {
          "ForAllValues:StringLike" : {
            "dynamodb:LeadingKeys" : [
              "*_$${accounts.google.com:sub}"
            ]
          }
        }
      }
    ]
  })
}

# Create Event
resource "aws_api_gateway_method" "create_event" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.db.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
}

resource "aws_api_gateway_integration" "create_event" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_method.create_event.resource_id
  http_method             = aws_api_gateway_method.create_event.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:dynamodb:action/PutItem"
  credentials             = aws_iam_role.api_gateway_role.arn

  request_templates = {
    "application/json" = <<EOF
{
  "TableName": "${aws_dynamodb_table.eventsV2.name}",
  "Item": {
    "id": {
      "S": "$context.authorizer.claims.sub"
    },
    "userId": {
      "S": "$context.authorizer.claims.sub"
    },
    "name": {
      "S": "$input.path('$.name')"
    },
    "description": {
      "S": "$input.path('$.description')"
    },
    "date": {
      "S": "$input.path('$.date')"
    }
  }
}
EOF
  }
}

# Response templates for all methods
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.db.id
  http_method = aws_api_gateway_method.create_event.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.db.id
  http_method = aws_api_gateway_method.create_event.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{}
EOF
  }
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
