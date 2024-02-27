variable "s3_regional_domain_name" {
  default = ""
}

variable "logging_bucket_regional_domain_name" {
  description = "The domain name of the s3 bucket used for logging Cloudfront requests"
}

variable "environment" {}

variable "alias_domain_name" {
  description = "The custom domain name which will be attached to the Cloudfront distribution"
}

variable "certificate_arn" {
  description = "The ACM certificate to provide ssl for the custom domain name"
}

variable "api_gateway_url" {
  description = "The API gateway URL to create an origin for"
}

variable "sse_kms_enabled" {
  description = "Is server side encryption by customer managed KMS key enabled"
  type        = bool
  default     = false
}
