terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote state backend (Azure Storage), configured via partial
  # configuration. No account keys, SAS tokens, or subscription IDs are
  # hardcoded here — concrete values are supplied at `terraform init` time
  # via a gitignored backend.hcl file (see docs/backend.md).
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
      graceful_shutdown          = false
    }
  }
}
