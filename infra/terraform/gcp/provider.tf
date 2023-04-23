terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.service_account_key_path)

  project = var.gcp_project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}