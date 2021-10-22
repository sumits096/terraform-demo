terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

locals {
  timestamp = formatdate("YYMMDDhhmmss", timestamp())
    root_dir = abspath("../")
}

provider "google" {
  credentials = file("service-account.json")
  project = var.project
  region  = var.region
  zone    = "us-central1-c"
}

# Compress source code
data "archive_file" "source" {
  type = "zip"
  source_dir = "${path.module}"
  output_path = "${path.module}/source.zip"
}

# Create bucket that will host the source code
resource "google_storage_bucket" "bucket" {
  name = "${var.project}-function"
}

# Add source code zip to bucket
resource "google_storage_bucket_object" "zip" {
  # Append file MD5 to force bucket to be recreated
  name   = "source.zip#${data.archive_file.source.output_md5}"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.source.output_path
}

# Enable Cloud Functions API
resource "google_project_service" "cf" {
  project = var.project
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Cloud Build API
resource "google_project_service" "cb" {
  project = var.project
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  project = var.project
  service = "run.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = true
}

# Deploy image to Cloud Run
resource "google_cloud_run_service" "cloud_run_service" {
  name     = "cloud-run-service"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Create public access
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

# Enable public access on Cloud Run service
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.cloud_run_service.location
  project     = google_cloud_run_service.cloud_run_service.project
  service     = google_cloud_run_service.cloud_run_service.name
  policy_data = data.google_iam_policy.noauth.policy_data
}