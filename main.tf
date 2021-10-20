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
}

provider "google" {
  credentials = file("service-account.json")
  project = var.project
  region  = var.region
  zone    = "us-central1-c"
}


resource null_resource dummy_trigger {
  triggers = {
    timestamp = timestamp()
  }
}

resource "google_storage_bucket" "cloud-functions" {
  project       = var.project
  name          = "${var.project}-cloud-functions"
  location      = var.region
}

resource "google_storage_bucket_object" "start_instance" {
  name       = "start_instance.zip"
  bucket     = google_storage_bucket.cloud-functions.name
  source     = "${path.module}/start_instance.zip"
  depends_on = [
    data.archive_file.start_instance,
  ]
}

data "archive_file" "start_instance" {
  type        = "zip"
  output_path = "${path.module}/start_instance.zip"

  source {
    content  = file("${path.module}/scripts/start_instance/index.js")
    filename = "index.js"
  }

  source {
    content  = file("${path.module}/scripts/start_instance/package.json")
    filename = "package.json"
  }
  
  depends_on = [
    resource.null_resource.dummy_trigger,
  ]
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

# Create Cloud Function
resource "google_cloudfunctions_function" "function" {
  name    = "function-test"
  runtime = "nodejs12"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.zip.name
  trigger_http          = true
  entry_point           = "helloword"
}

# Create IAM entry so all users can invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
