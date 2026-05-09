terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rg-workload-identity-lab"
  location = var.location
}

# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "github" {
  name                = "uai-github-actions"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# Federated Identity Credential (GitHub OIDC)
resource "azurerm_federated_identity_credential" "github" {
  name                = "github-federated-cred"
  resource_group_name = azurerm_resource_group.main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.github.id
  subject             = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
}

# Give the identity permissions (example: Contributor on this RG)
resource "azurerm_role_assignment" "github_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

output "managed_identity_client_id" {
  value = azurerm_user_assigned_identity.github.client_id
}

output "managed_identity_object_id" {
  value = azurerm_user_assigned_identity.github.principal_id
}
