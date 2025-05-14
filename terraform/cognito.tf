# Cognito User Pool that allows only Google Sign-In

resource "aws_cognito_user_pool" "this" {
  name = "${var.app_name}-user-pool"

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "given_name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "family_name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "picture"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "${var.app_name}-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.this.id
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO", "Google"]
  callback_urls                        = ["https://${var.webapp_subdomain}.${var.domain_name}/"]
  logout_urls                          = ["https://${var.webapp_subdomain}.${var.domain_name}/"]

  write_attributes = [
    "email",
    "profile",
    "name",
    "given_name",
    "family_name",
    "picture"
  ]
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"
  provider_details = {
    client_id        = var.cognito_google_client_id
    client_secret    = var.cognito_google_client_secret
    authorize_scopes = "email profile openid"
  }

  attribute_mapping = {
    email          = "email"
    email_verified = "email_verified"
    username       = "sub"
    name           = "name"
    given_name     = "given_name"
    family_name    = "family_name"
    picture        = "picture"
    locale         = "locale"
  }

  lifecycle {
    ignore_changes = [provider_details]
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.this.id
}

# Identity Pool that allows only Google Sign-In

resource "aws_cognito_identity_pool" "this" {
  identity_pool_name               = "${var.app_name}-identity-pool"
  allow_unauthenticated_identities = false

  supported_login_providers = {
    "accounts.google.com" = var.cognito_google_client_id
  }

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = "cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
    server_side_token_check = true
  }

  # roles = {
  #   authenticated = aws_iam_role.cognito_authenticated.arn
  # }
}

resource "aws_cognito_identity_pool_roles_attachment" "google" {
  identity_pool_id = aws_cognito_identity_pool.this.id

  roles = {
    authenticated = aws_iam_role.cognito_authenticated.arn
    # unauthenticated = aws_iam_role.cognito_unauthenticated.arn
  }
}

resource "aws_iam_role" "cognito_authenticated" {
  name = "${var.app_name}-cognito-authenticated"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cognito_authenticated_policy" {
  name = "${var.app_name}-cognito-authenticated-policy"
  role = aws_iam_role.cognito_authenticated.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*"
        ]
        Resource = "*"
      }
    ]
  })
}

output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.this.id
}
