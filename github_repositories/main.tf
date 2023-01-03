data "github_repository" "repository" {
  full_name = var.repository_name
}

resource "github_actions_secret" "repository_secret" {
  for_each        = var.secrets
  repository      = data.github_repository.repository.name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_dependabot_secret" "repository_secret" {
  for_each        = var.dependabot_secrets
  repository      = data.github_repository.repository.name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_repository_collaborator" "collaborators" {
  for_each   = var.collaborators
  repository = data.github_repository.repository.name
  username   = each.value
}
