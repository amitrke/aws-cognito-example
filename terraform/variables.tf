variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "myapp"
}

variable "webapp_files" {
  description = "The path to the webapp files"
  type        = string
  default     = "../webapp/dist/webapp/browser"
}

#Cognito

variable "cognito_google_client_id" {
  description = "Google Client ID for Cognito"
  type        = string
}

variable "cognito_google_client_secret" {
  description = "Google Client Secret for Cognito"
  type        = string
}

variable "cognito_domain" {
  description = "Cognito Domain"
  type        = string
  default     = "amrke-myapp"
}
