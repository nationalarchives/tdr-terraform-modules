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
  description = "The shell script text to be run when the instance starts"
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

variable "role_name" {
  default     = ""
  description = "Allows the role for the instance to be overridden with a different one."
}

variable "user_data_list" {
  default = []
}
