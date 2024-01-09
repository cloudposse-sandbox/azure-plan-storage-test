data "azuread_client_config" "this" {}


resource "azuread_application" "github_oidc" {
  display_name = "${var.prefix}"
owners       = [data.azuread_client_config.this.object_id]

  api {
    requested_access_token_version = 2
  }
}

resource "azuread_service_principal" "github_oidc" {
  client_id = azuread_application.github_oidc.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.this.object_id]
}

 resource "azurerm_role_assignment" "this" {
   scope                = azurerm_resource_group.identity.id
   role_definition_name = "Contributor"
   principal_id         = azuread_service_principal.github_oidc.id

 }

 resource "azuread_application_federated_identity_credential" "github_oidc" {
   application_object_id = azuread_application.github_oidc.object_id
   display_name          = "cloudposse-sandbox-azure-plan-storage-test"
   description           = "Deployments for cloudposse-sandbox/azure-plan-storage-test"
   audiences             = [local.default_audience_name]
   issuer                = local.github_issuer_url
   subject               = "repo:cloudposse-sandbox/azure-plan-storage-test:ref:refs/heads/main"
 }
