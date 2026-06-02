# variables.tf for module: app-service

# ------------------------------------------------

# from module: platfrom
variable "rg_name" {
}
/* variable "rg_location" {
} */
variable "appservice_deploy_location" {
  type = string
  default = "eastus"
}

# LAW id - from monitoring module
variable "law_id" {
}

# App service plan
variable "asp_name" {
  type = string
  default = "cnsolns-asp-spa"
}

# Linux Web App
variable "linux_web_app_spa_name" {
  type = string
  default = "cnsolns-spa"
}


# App settings
/* variable "APP_ENV" {
  type = string
  default = "Prod"
}
variable "API_BASE_URI" {
  type = string
  default = "https://api.cnsolnsspa.com"
}
variable "FEATURE_FLAG_X" {
  type = string
  default = "true"
} */

/* variable "app_settings" {
  type = map(string)
  description = "Custom application settings (environment variables) for the App Service"
  default     = {}
} */

