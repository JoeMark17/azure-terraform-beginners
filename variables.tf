##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "resource_group_dev" {
  description = "The name of your Azure Resource Group."
  default     = "analytics8-etlfunctions-development-rg"
}

variable "resource_group_prod" {
  description = "The name of your Azure Resource Group."
  default     = "analytics8-etlfunctions-development-rg"
}
