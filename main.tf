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
  region  = "us-west2"
  zone    = "us-west2-a"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_project" "terraform-first-app" {
  name       = "terraform-first-app"
  project_id = "terraform-first-app"
  org_id     = "1001419021452"
}

resource "google_app_engine_application" "app" {
  project     = google_project.terraform-first-app.project_id
  location_id = "us-west"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}
