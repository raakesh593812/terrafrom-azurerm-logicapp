variable "resource_group_name" {
  type = string
  
}

variable "logic_app_type" {
  type = string
  description = "use either standard or workflow"
  default = "workflow"
  
}
variable "storage_account_create" {
  type = bool
  default = false
  
}

variable "storage_account_name" {
  type = string
  default = null
 
}



variable "app_service_plan_name" {
  type = string
 default = null
}


variable "log_analytics_workspace_name" {
  type = string
 default = null
}

variable "log_analytics_workspace_name_rg" {
  type = string
 default = null
}
variable "azurerm_application_insights_name" {
  type = string
  default = null
}
variable "logic_app_name" {
  type = string
  
}

variable "identity" {
  description = "If you want your logic app to have an managed identity. Defaults to false."
  default     = false
}

variable "enable_log_analytics_workspace" {
  type = bool
  default = false

}
variable "enable_application_insights" {
  type = bool
  default = false

}

variable "extaudit_diag_logs" {
  description = "Database Monitoring Category details for Azure Diagnostic setting"
  default     = ["WorkflowRuntime"]
}

variable "service_plan" {
  description = "Definition of the dedicated plan to use"
  type = object({
    os_type          = string
    sku_name         = string
    app_service_environment_id = optional(string)
    maximum_elastic_worker_count = optional(number)
    worker_count    = optional(number)
     per_site_scaling_enabled = optional(bool)
     zone_balancing_enabled  = optional(bool)
  })
}
variable "custom_app_action_body" {
  
}

variable "schema_body" {
  
}
variable "custom_app_action2_body" {
  
}