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

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "IX"
    workspaces = {
          name = "terraform-demo"
    }
  }
}