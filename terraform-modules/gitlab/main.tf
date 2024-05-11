resource "gitlab_project" "this" {
  name        = var.gitlab_project_name
  description = var.gitlab_project_description

  visibility_level = var.is_public ? "public" : "private"
}
