# Cognito User Pool that allows only Google Sign-In

resource "aws_cognito_user_pool" "this" {
  name = "${var.app_name}-user-pool"
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "${var.app_name}-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.this.id
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  #supported_identity_providers         = ["COGNITO", "Google"]
  callback_urls                        = ["https://app.subnext.com/login"]
  logout_urls                          = ["https://your-redirect-url.com/signout"]

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
    email    = "email"
    email_verified = "email_verified"
    username = "sub"
    name     = "name"
    given_name = "given_name"
    family_name = "family_name"
    picture = "picture"
    locale = "locale"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.this.id
}

# Identity Pool that allows only Google Sign-In

resource "aws_cognito_identity_pool" "this" {
  identity_pool_name = "${var.app_name}-identity-pool"
  allow_unauthenticated_identities = false

  supported_login_providers = {
    "accounts.google.com" = var.cognito_google_client_id
  }

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = "cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
    server_side_token_check = false
  }
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