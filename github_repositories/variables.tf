variable "repository_name" {}

variable "secrets" {
  default = {}
}

variable "dependabot_secrets" {
  default = {}
}

variable "collaborators" {

  description = "Outside collaborators to add to the repository. This is for GitHub users who are not part of the nationalrchives organisation but who need access to a repository"
  default     = []
  type        = set(string)
}
