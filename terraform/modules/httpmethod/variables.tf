variable "apigw_id" {
    type = string
    description = "The ID of the API Gateway"
}

variable "apigw_resource_id" {
    type = string
    description = "The ID of the API Gateway resource"
}

variable "http_method" {
    type = string
    description = "The HTTP method"
}

variable "lambda_arn" {
    type = string
    description = "The ARN of the Lambda function"
}

variable "authorization" {
    type = string
    description = "The authorization type"
    default = "NONE"
}

variable "authorizer_id" {
    type = string
    description = "The ID of the authorizer"
    default = ""
}