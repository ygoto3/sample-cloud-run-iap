terraform {
  backend "gcs" {
    bucket  = var.tf_bucket 
  }
}
