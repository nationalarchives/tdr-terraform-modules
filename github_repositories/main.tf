data "github_repository" "repository" {
  full_name = var.repository_name
}

resource "github_actions_secret" "repository_secret" {
  for_each        = var.secrets
  repository      = data.github_repository.repository.name
  secret_name     = each.key
  plaintext_value = each.value
}
