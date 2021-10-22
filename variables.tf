variable "project" {
    default = "terraform-deployment-demo"
}

variable "region" {
    default = "us-central1" # Choose a region
}

variable "github_repository" {
    default = ""
}

variable "github_owner" {
    default = "sumitshinde096@gmail.com"
}

variable "github_branch" {
    default = "^master$"
}