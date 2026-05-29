# main.tf for module: app-service

/* 
Deployed

 - App service plan
 - Linux Web App (Stand alone) - for static SPA
 - Diagnostic setting for web app


wired this web app with GitHub actions pipeline so that it will be deployed in App service along with infra deployment

*/

# ------------------------------------------------

# tags
locals {
  common_tags = {
    author = "HK"
    env = "Prod"
  }
}

# App service plan
resource "azurerm_service_plan" "asp_spa" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.asp_name

  os_type = "Linux"

  sku_name = "S1"

  tags = local.common_tags
}

# Linux Web App
resource "azurerm_linux_web_app" "linux_web_app_spa" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.linux_web_app_spa_name
  service_plan_id = azurerm_service_plan.asp_spa.id

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"
    ftps_state = "Disabled"

    application_stack {
      node_version = "18-lts"
    }
    always_on = true
  }

  /* app_settings = merge(
    {
        "WEBSITE_RUN_FROM_PACKAGE" = "1"
        "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
    },
    var.app_settings
  ) */

  tags = local.common_tags
}

# Diagnostic setting for Web App
resource "azurerm_monitor_diagnostic_setting" "linuz_web_app_spa_diagnostic_setting" {
    name = "${var.linux_web_app_spa_name}-diagnostic-setting"
    target_resource_id = azurerm_linux_web_app.linux_web_app_spa.id // web app's id
    log_analytics_workspace_id = var.law_id // from module: monitoring

    enabled_log {
      category = "AppServiceHTTPLogs"
    }
    enabled_log {
      category = "AppServiceConsoleLogs"
    }
    metric {
      category = "AllMetrics"
      enabled = true
    }
}