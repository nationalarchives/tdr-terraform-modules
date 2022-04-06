variable "repository_name" {}

variable "environment" {}

variable "team_slug" {}

variable "integration_team_slug" {
  description = "This repository needs approvals on integration as well. This is the team name which can approve deployments on integration"
  default     = []
}

variable "secrets" {
  default = {}
}
