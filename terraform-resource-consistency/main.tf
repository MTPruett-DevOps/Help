terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

module "standard" {
  source = "Azure/naming/azurerm"

  suffix = [
    join("-", compact([
      lower(var.Environment),
      lower(var.AssetName),
      lower(var.Project)
    ]))
  ]
}

module "compact" {
  source = "Azure/naming/azurerm"

  suffix = [
    join("", compact([
      lower(var.Environment),
      lower(var.AssetName),
      lower(var.Project)
    ]))
  ]
}