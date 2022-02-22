data "github_repository" "repository" {
  full_name = var.repository_name
}

data "github_team" "team" {
  slug = var.team_slug
}

resource "github_repository_environment" "environment" {
  environment = var.environment
  repository  = data.github_repository.repository.name
  dynamic "reviewers" {
    for_each = var.environment == "intg" ? [] : [var.team_slug]
    content {
      teams = [data.github_team.team.id]
    }
  }
}

resource "github_actions_secret" "repository_secret" {
  for_each        = var.secrets
  repository  = data.github_repository.repository.name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_actions_environment_secret" "secret" {
  for_each        = var.secrets
  environment     = github_repository_environment.environment.environment
  repository      = data.github_repository.repository.name
  secret_name     = each.key
  plaintext_value = each.value
}
