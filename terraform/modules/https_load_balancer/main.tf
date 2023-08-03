# IAP settings
resource "google_iap_web_backend_service_iam_binding" "app-iam-binding" {
  web_backend_service = google_compute_backend_service.app.name
  role = "roles/iap.httpsResourceAccessor"
  members = ${var.iap_members}
}

# Static IP address
resource "google_compute_global_address" "load-balancer-address" {
  name     = "load-balancer-address"
  project  = "${var.project_id}"
}

# Load balancer's backend settings
resource "google_compute_backend_service" "app" {
  name        = "backend-app"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.app.id
  }

  iap {
    oauth2_client_id = "${var.oauth2_client_id}"
    oauth2_client_secret = "${var.oauth2_client_secret}"
  }
}

# Load balancer's NEG settings
resource "google_compute_region_network_endpoint_group" "app" {
  name                  = "app-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "${var.location}"
  cloud_run {
    service = "${var.backend_service_name}"
  }
}

# URL mapping to backend
resource "google_compute_url_map" "url-map" {
  name = "url-map"

  default_service = google_compute_backend_service.app.id

  host_rule {
    hosts        = var.cert_domains
    path_matcher = "app"
  }

  path_matcher {
    name            = "app"
    default_service = google_compute_backend_service.app.id
  }
}

# Frontend settings
resource "google_compute_global_forwarding_rule" "forwarding-rule" {
  name        = "frontend"
  target      = google_compute_target_https_proxy.https-proxy.id
  ip_address  = google_compute_global_address.load-balancer-address.id
  ip_protocol = "TCP"
  port_range  = "443"
}

# SSL settings
resource "google_compute_target_https_proxy" "https-proxy" {
  name             = "${var.project_id}-proxy"
  url_map          = google_compute_url_map.url-map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl-certificate.id]
  ssl_policy       = google_compute_ssl_policy.ssl-policy.id
}

# Manage SSL certificate : Add random prefix to name to rotate certificate every time
resource "google_compute_managed_ssl_certificate" "ssl-certificate" {
  name = "terraform-${random_id.certificate.hex}"

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = var.cert_domains
  }
}

resource "google_compute_ssl_policy" "ssl-policy" {
  name            = "${var.project_id}-ssl-policy"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

# Generate random ID for SSL certificate
resource "random_id" "certificate" {
  byte_length = 4
  prefix      = "${var.project_id}-cert-"

  keepers = {
    domains = join(",", var.cert_domains)
  }
}
