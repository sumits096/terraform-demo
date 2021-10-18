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

resource "google_project" "terraform-first-app" {
  name       = "terraform-first-app"
  project_id = "terraform-first-app"
  org_id     = "12345677"
}

resource "google_app_engine_application" "app" {
  project     = google_project.terraform-first-app.project_id
  location_id = "us-central"
}