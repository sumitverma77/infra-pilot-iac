variable "role_name" {
  type        = string
  description = "Name of the IAM role to create"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub OIDC provider"
}

variable "github_org" {
  type        = string
  description = "GitHub organization or username"
}

variable "match_subjects" {
  type        = list(string)
  description = "List of full subject strings to match (e.g. repo:org/repo:environment:stage)"
}

variable "managed_policies" {
  type        = list(string)
  default     = []
  description = "List of managed IAM policy ARNs to attach to the role"
}
