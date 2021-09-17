variable "s3_regional_domain_name" {
  default = ""
}

variable "logging_bucket_regional_domain_name" {
  description = "The domain name of the s3 bucket used for logging Cloudfront requests"
}

variable "environment" {}
