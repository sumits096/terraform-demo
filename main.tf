terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("service-account.json")
  project = "terraform-first-app"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_cloud_run_service" "terraform-cloud-run" {
  name     = "terraform-first-app"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
}

