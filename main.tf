provider "azurerm" {
    skip_provider_registration = true
    features {
        key_vault {
	        recover_soft_deleted_key_vaults = true
            purge_soft_delete_on_destroy = true
        }
    }
}
module "logic_app" {
  source  = "./module/logicapp"
logic_app_type = "standard"
storage_account_create = true
storage_account_name = "rtxxzxmlik"
resource_group_name = "terr-import-rg" 
logic_app_name = "pra-la-xx-ww" 
log_analytics_workspace_name = "DefaultWorkspace-7493c606-7d9a-48cb-8bb3-eca30de998c9-CUS"
log_analytics_workspace_name_rg = "defaultresourcegroup-cus"
app_service_plan_name = "la-app-service-plan"
service_plan = {
     os_type          = "Linux"
    sku_name         = "P1v2"

}

}

