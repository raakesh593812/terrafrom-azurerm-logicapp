locals {
  
  }
data "azurerm_resource_group" "rgrp" {
    name  = var.resource_group_name
}

data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "logicapp_std_storage" {
   count                    = var.logic_app_type == "standard" && var.storage_account_create == true ? 1 : 0
    name                     = var.storage_account_name
    resource_group_name      = data.azurerm_resource_group.rgrp.name
    location                 = data.azurerm_resource_group.rgrp.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}
#Create a plan for the logic apps to run on
resource "azurerm_service_plan" "platform_logicapp_plan" {
    count                           = var.logic_app_type == "standard" ? 1 : 0
    name                            = var.app_service_plan_name
    location                        = data.azurerm_resource_group.rgrp.location
    resource_group_name             = data.azurerm_resource_group.rgrp.name
    os_type                         = var.service_plan.os_type
    sku_name                        = var.service_plan.sku_name
    app_service_environment_id      = var.service_plan.app_service_environment_id
    maximum_elastic_worker_count    = var.service_plan.maximum_elastic_worker_count
    worker_count                    = var.service_plan.worker_count
    per_site_scaling_enabled        = var.service_plan.per_site_scaling_enabled
    zone_balancing_enabled          = var.service_plan.zone_balancing_enabled
}


#Create an app insights instance for the logic apps to send telemetry to
resource "azurerm_application_insights" "platform_logicapp_appinsights" {
    count               = var.logic_app_type == "standard" && var.enable_application_insights == true ? 1 : 0
    name                = var.azurerm_application_insights_name
    location            = data.azurerm_resource_group.rgrp.location
    resource_group_name = data.azurerm_resource_group.rgrp.name
    application_type    = "web"
    workspace_id        = data.azurerm_log_analytics_workspace.logws.0.id
}

#Create a Logic App on the plan
resource "azurerm_logic_app_standard" "logicapp_std" {
    count = var.logic_app_type == "standard" ? 1 : 0
    name                        = var.logic_app_name
    location                    = data.azurerm_resource_group.rgrp.location
    resource_group_name         = data.azurerm_resource_group.rgrp.name
    app_service_plan_id         = azurerm_service_plan.platform_logicapp_plan.0.id
    storage_account_name        = azurerm_storage_account.logicapp_std_storage.0.name
    storage_account_access_key  = azurerm_storage_account.logicapp_std_storage.0.primary_access_key
 

    

  dynamic "identity" {
    for_each = var.identity == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }
}

resource "azurerm_logic_app_workflow" "la_workflow" {
  count = var.logic_app_type == "workflow" ? 1 : 0
  name                = var.logic_app_name
  location                    = data.azurerm_resource_group.rgrp.location
  resource_group_name         = data.azurerm_resource_group.rgrp.name


  dynamic "identity" {
    for_each = var.identity == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }
}


data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_name_rg
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  count                      = var.log_analytics_workspace_name != null ? 1 : 0
  name                       = lower("audit-${var.logic_app_name}-diag")
 target_resource_id = azurerm_logic_app_workflow.la_workflow.0.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logws.0.id

dynamic "log" {
    for_each = var.extaudit_diag_logs
    content {
      category = log.value
      enabled  = true
      retention_policy {
        enabled = false
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }



}

# resource "azurerm_logic_app_action_custom" "example" {
#   name         = "example-action"
#   logic_app_id = azurerm_logic_app_workflow.la_workflow.0.id

#   body = <<BODY
# {
#     "description": "A variable to configure the auto expiration age in days. Configured in negative number. Default is -30 (30 days old).",
#     "inputs": {
#         "variables": [
#             {
#                 "name": "ExpirationAgeInDays",
#                 "type": "Integer",
#                 "value": -30
#             }
#         ]
#     },
#     "runAfter": {},
#     "type": "InitializeVariable"
# }
# BODY

# }
# resource "azurerm_logic_app_trigger_recurrence" "example" {
#   name         = "run-every-day"
#   logic_app_id = azurerm_logic_app_workflow.la_workflow.0.id
#   frequency    = "Day"
#   interval     = 1
# }