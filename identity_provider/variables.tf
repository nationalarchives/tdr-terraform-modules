variable "thumbprint_list" {
  description = "List of the thumbprints for the OIDC provider. These are public"
  type        = list(string)
}

variable "audience" {
  description = "The audience for the OIDC provider"
}

variable "url" {
  description = "The url for the OIDC provider"
}

variable "common_tags" {}
