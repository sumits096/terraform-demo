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
  project = var.project
  region  = var.region
  zone    = "us-central1-c"
}

resource "google_project_service" "api" {
 for_each = toset([
  "cloudresourcemanager.googleapis.com",
  "compute.googleapis.com"
 ])
 disable_on_destroy = false
 service = each.value
}

resource "google_compute_firewall" "web" {
  name    = "web-access"
  network = "default"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }
}

resource "google_compute_instance" "my_web_server" {
  name         = "my-gcp-web-server"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<EOF "echo hi > /test.txt" 
  EOF

  depends_on = [google_project_service.api, google_compute_firewall.web]
}

