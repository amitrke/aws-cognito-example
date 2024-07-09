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
  callback_urls                        = ["https://your-redirect-url.com/callback"]
  logout_urls                          = ["https://your-redirect-url.com/signout"]
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
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.this.id
}
