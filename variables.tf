variable "location" {
  default = "westus2"
}

variable "github_org" {
  description = "Your GitHub username or organization"
  default     = "javierafloresgarcia20-png"
}

variable "github_repo" {
  description = "Repository name that will use this identity"
  default     = "azure-aks-terraform"
}
