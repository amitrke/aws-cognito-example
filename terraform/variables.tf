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

variable "domain_name" {
  description = "The domain name for the webapp"
  type        = string
}

variable "webapp_subdomain" {
  description = "The subdomain for the webapp"
  type        = string
  default     = "app"  
}

variable "api_subdomain" {
  description = "The subdomain for the API"
  type        = string
  default     = "api"
}

variable "certificate_arn" {
  description = "The ARN of the certificate for the domain"
  type        = string
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

variable stage_name {
  default = "prod"
  type    = string
}