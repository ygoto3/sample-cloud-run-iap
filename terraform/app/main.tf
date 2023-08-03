# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

module "cloud_run" {
  depends_on = [google_project_service.run_api]

  source = "../modules/cloud_run"

  project_id = "${var.project_id}"
  service_name = "${var.service_name}"
  location = "${var.region}"
  image_id = "${var.image_id}"
}

module "https_load_balancer" {
  depends_on = [google_project_service.run_api]

  source = "../modules/https_load_balancer"

  project_id = "${var.project_id}"
  location = "${var.region}"
  backend_service_name = "${var.service_name}"
  iap_members = "${var.iap_members}"
  cert_domains = "${var.cert_domains}"
  oauth2_client_id = "${var.oauth2_client_id}"
  oauth2_client_secret = "${var.oauth2_client_secret}"
}
