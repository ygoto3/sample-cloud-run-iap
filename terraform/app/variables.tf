variable "tf_bucket" {
  type    = string
}

variable "project_id" {
  type    = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "service_name" {
  type    = string
  default = "my-cloud-run-service"
}

variable "image_id" {
  type    = string
  default = "my-image"
}

variable "cert_domains" {
  type    = list(string)
}

variable "iap_members" {
  type    = list(string)
}

variable "oauth2_client_id" {
  type    = string
}

variable "oauth2_client_secret" {
  type    = string
}
