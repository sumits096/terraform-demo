output "project_id" {
  value = var.project_name
}

output "url" {
  value = "${google_cloud_run_service.gcp_cloud_run_service.status[0].url}"
}

output "repository_http_url" {
  description = "HTTP URL of the repository in Cloud Source Repositories."
  value       = google_sourcerepo_repository.repo.url
}

output "google_service_account_email" {
  value = google_service_account.service_account.email
}
