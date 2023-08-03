resource "google_cloud_run_service" "default" {
  name     = "${var.service_name}"
  location = "${var.location}"
 
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${var.image_id}"
      }
    }
  }
}
 
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
 
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
 
  policy_data = data.google_iam_policy.noauth.policy_data
}
