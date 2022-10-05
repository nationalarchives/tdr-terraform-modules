variable "repository_name" {}

variable "secrets" {
  default = {}
}

variable "collaborators" {
  description = "Outside collaborators to add to the repository"
  default     = []
  type        = set(string)
}
