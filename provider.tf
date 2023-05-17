# Declare a standard provider block using your preferred configuration.
# This will target the "default" Subscription and be used for the deployment of all "Core resources".
# provider "azurerm" {
#   features {}
# }

# Declare an aliased provider block using your preferred configuration.
# This will be used for the deployment of all "Connectivity resources" to the specified `subscription_id`.
provider "azurerm" {
  alias           = "connectivity"
  subscription_id = "00000000-0000-0000-0000-000000000000"
  features {}
}

# Declare a standard provider block using your preferred configuration.
# This will be used for the deployment of all "Management resources" to the specified `subscription_id`.
provider "azurerm" {
  alias           = "management"
  subscription_id = "11111111-1111-1111-1111-111111111111"
  features {}
}

# Obtain client configuration from the un-aliased provider
# data "azurerm_client_config" "core" {
#   provider = azurerm
# }

# Obtain client configuration from the "management" provider
data "azurerm_client_config" "management" {
  provider = azurerm.management
}

# Obtain client configuration from the "connectivity" provider
data "azurerm_client_config" "connectivity" {
  provider = azurerm.connectivity
}

# Map each module provider to their corresponding `azurerm` provider using the providers input object
module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "4.0.1" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints
  
  default_location = "eastus"
  providers = {
    # azurerm              = azurerm
    azurerm.management   = azurerm.management
    azurerm.connectivity = azurerm.connectivity
  }

  # Set the required input variable `root_parent_id` using the Tenant ID from the un-aliased provider
  root_parent_id = data.azurerm_client_config.core.tenant_id

  root_id        = var.root_id
  root_name      = var.root_name

  # Enable deployment of the management resources, using the management
  # aliased provider to populate the correct Subscription ID
  deploy_management_resources = var.deploy_management_resources
  subscription_id_management  = data.azurerm_client_config.management.subscription_id
  configure_management_resources = local.configure_management_resources
  # Enable deployment of the connectivity resources, using the connectivity
  # aliased provider to populate the correct Subscription ID
  deploy_connectivity_resources = var.deploy_connectivity_resources
  subscription_id_connectivity  = data.azurerm_client_config.connectivity.subscription_id
  configure_connectivity_resources = local.configure_connectivity_resources

  # # Enable deployment of the connectivity resources, using the connectivity
  # # aliased provider to populate the correct Subscription ID
  # deploy_identity_resources    = var.deploy_identity_resources
  # subscription_id_identity     = data.azurerm_client_config.core.subscription_id
  # configure_identity_resources = local.configure_identity_resources


  # insert additional optional input variables here

}