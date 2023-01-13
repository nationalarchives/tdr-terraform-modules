variable "function_name" {
  description = "The name of the lambda function"
}

variable "handler" {
  description = "The lambda function handler"
}

variable "kms_key_arn" {
  description = "The kms key to use to encrypt environment variables if necessary"
  default     = ""
}

variable "encrypted_env_vars" {
  default     = {}
  type        = map(string)
  description = "A map of environment variables in the form ENV_VAR_NAME -> plaintext value These will be encrypted"
}

variable "plaintext_env_vars" {
  default     = {}
  type        = map(string)
  description = "A map of environment variables in the form ENV_VAR_NAME -> plaintext value These will not be encrypted"
}

variable "runtime" {
  description = "The lambda runtime, for example java11"
}

variable "timeout_seconds" {
  default = 15
}

variable "memory_size" {
  default = 1024
}

variable "reserved_concurrency" {
  default = 1
}

variable "tags" {}

variable "efs_access_points" {
  type = list(object({
    access_point_arn = string,
    mount_path       = string
  }))
  default     = []
  description = "A list of access point arns and mount paths. This can be ommitted if EFS is not needed"
}

variable "vpc_config" {
  type = list(object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  }))
}

variable "lambda_sqs_queue_mappings" {
  type        = set(string)
  default     = []
  description = "A list of sqs queues which can trigger this lambda"
}

variable "role_name" {
  description = "The lambda execution role name. The role will be created by the module"
}

variable "storage_size" {
  default     = 512
  description = "The amount of disk storage available in the lambdas /tmp directory"
}

variable "lambda_invoke_permissions" {
  description = "A list of principals and source arns to be allowed to call lambda:InvokeFunction"
  type        = map(string)
  default     = {}
}

variable "policies" {
  description = "A map in the form policyName -> policyBodyString"
  type        = map(string)
}

variable "policy_attachments" {
  type        = set(string)
  default     = []
  description = "A list of policy arns to attach. These will need to be pre-existing policies"
}
