module "test_terraform" {
  source = "../../terraform-modules/gitlab"

  gitlab_project_name        = "test-gitlab-terraform"
  gitlab_project_description = "Set up gitlab project using terraform"
}