data "github_repository" "repository" {
  full_name = var.repository_name
}

data "github_team" "team" {
  count = var.team_slug == "" ? 0 : 1
  slug  = var.team_slug
}

data "github_team" "integration_team" {
  count = length(var.integration_team_slug)
  slug  = var.integration_team_slug[count.index]
}

resource "github_repository_environment" "environment" {
  environment = var.environment
  repository  = data.github_repository.repository.name
  reviewers {
    teams = var.environment == "intg" ? data.github_team.integration_team.*.id : data.github_team.team.*.id
  }
}

resource "github_actions_environment_secret" "secret" {
  for_each        = var.secrets
  environment     = github_repository_environment.environment.environment
  repository      = data.github_repository.repository.name
  secret_name     = each.key
  plaintext_value = each.value
}
