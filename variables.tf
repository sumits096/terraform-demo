variable "project" {
    default = "terraform-deployment-demo"
}

variable "region" {
    default = "us-central1" # Choose a region
}

variable "github_repository" {
    default = "https://github.com/sumitshinde/terraform-demo.git"
}

variable "github_owner" {
    default = "sumitshinde096@gmail.com"
}

variable "github_branch" {
    default = "^master$"
}