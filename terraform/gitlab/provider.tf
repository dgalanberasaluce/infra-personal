terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "16.11.0"
    }
  }
}

provider "gitlab" {
#   token = var.gitlab_token # GITLAB_TOKEN env variable
}
