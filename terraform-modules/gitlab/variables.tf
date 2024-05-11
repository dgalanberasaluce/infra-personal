variable "gitlab_project_name" {
  description = "The name of the project"
  type        = string
}

variable "gitlab_project_description" {
  description = "A description of the project"
}

variable "is_public" {
  description = "Whether the project is public"
  type        = bool
  default     = false
}

variable "default_branch" {
  description = "The default branch name for the project"
  type        = string
  default     = "main"
}