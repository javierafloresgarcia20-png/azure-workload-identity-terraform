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

# =============================================
# Resource Group
# =============================================
resource "azurerm_resource_group" "main" {
  name     = "rg-workload-identity-lab"
  location = var.location

  tags = {
    Environment = "Lab"
    Project     = "Workload-Identity-Federation"
    Purpose     = "GitHub-Actions-OIDC"
  }
}

# =============================================
# User Assigned Managed Identity
# =============================================
resource "azurerm_user_assigned_identity" "github" {
  name                = "uai-github-actions"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = {
    Environment = "Lab"
  }
}

# =============================================
# Federated Identity Credential (GitHub OIDC)
# =============================================
resource "azurerm_federated_identity_credential" "github" {
  name                = "github-federated-cred"
  resource_group_name = azurerm_resource_group.main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = azurerm_user_assigned_identity.github.id
  
  # More flexible: allows any branch, tag, or environment
  subject             = "repo:${var.github_org}/${var.github_repo}:*"
}

# =============================================
# Role Assignment - Limited permissions for safety in a lab
# =============================================
resource "azurerm_role_assignment" "github_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"        # Change to "Reader" if you want even less access
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

# =============================================
# Outputs
# =============================================
output "managed_identity_client_id" {
  description = "Client ID - Use this in GitHub Repository Secrets"
  value       = azurerm_user_assigned_identity.github.client_id
}

output "managed_identity_object_id" {
  description = "Object ID of the Managed Identity"
  value       = azurerm_user_assigned_identity.github.principal_id
}

output "resource_group_name" {
  description = "Resource Group where resources were created"
  value       = azurerm_resource_group.main.name
}
