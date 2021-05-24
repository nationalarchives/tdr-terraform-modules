variable "name" {
  description = "The name to use for the instance and the IAM role and policy if using"
}

variable "environment" {}

variable "common_tags" {
  type = map(string)
}

variable "ami_id" {}

variable "user_data" {
  default     = ""
  description = "The template name for the shell script which will be run when the instance starts"
}

variable "user_data_variables" {
  default     = {}
  type        = map(string)
  description = "The variables map to be passed into the user data template."
}

variable "security_group_id" {
  default = ""
}

variable "subnet_id" {}

variable "public_key" {
  default = ""
}

variable "instance_type" {
  default = "t2.micro"
}

variable "volume_size" {
  type    = number
  default = 30
}

variable "private_ip" {
  default = ""
}

variable "attach_policies" {
  description = "A list of policy arns to attach to the instance IAM role"
  type        = map(string)
  default     = {}
}
