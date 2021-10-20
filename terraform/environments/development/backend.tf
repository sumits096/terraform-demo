terraform {
  backend "gcs" {
    bucket = "terraform-deployment-demo-tfstate"
    prefix = "env/development"
  }
}