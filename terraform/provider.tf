terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.78.1"

cloud {
  organization = "Destian"

  workspaces {
    tags = ["stage", "prod"]
   }
 }
}
  # backend "s3" {
  #   endpoint   = "storage.yandexcloud.net"
  #   bucket     = "terraform-storage-destian"
  #   region     = "ru-central1"
  #   key        = ".terraform/terraform.tfstate"
  #   access_key = "-"
  #   secret_key = ""

  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  # }


provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
  zone = "ru-central1-a"
}
