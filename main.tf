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

resource "google_project" "my_project" {
  name       = "My Project"
  project_id = "terraform-first-app"
  org_id     = "1234567"
}

resource "google_app_engine_application" "app" {
  project     = google_project.my_project.project_id
  location_id = "us-central"
}