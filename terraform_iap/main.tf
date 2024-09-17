terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  default = "as-dev-ga4-flattener-320623"
}

variable "region" {
  default = "us-central1"
}

variable "cloud_run_service" {
  default = "cloud-run-service"
}

variable "user_email" {
    default = "ruslan.bergenov@adswerve.com"
}

# Enable required APIs
resource "google_project_service" "enable_apis" {
  for_each = toset([
    "iap.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudidentity.googleapis.com",
    "compute.googleapis.com"
  ])
  service = each.key
  disable_on_destroy = false
}

# Create Serverless NEG
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "demo-iap-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = var.cloud_run_service
  }
}

# Create Backend Service
resource "google_compute_backend_service" "backend" {
  name        = "demo-iap-backend"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

# Create URL Map
resource "google_compute_url_map" "url_map" {
  name            = "demo-iap-url-map"
  default_service = google_compute_backend_service.backend.id
}

# Reserve Static IP
resource "google_compute_global_address" "static_ip" {
  name = "demo-iap-ip"
}

# Create SSL Certificate
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "demo-iap-cert"
  managed {
    domains = ["${google_compute_global_address.static_ip.address}.nip.io"]
  }
}

# Create HTTPS Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "demo-iap-http-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.id]
}

# Create Forwarding Rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "demo-iap-forwarding-rule"
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.static_ip.address
}



# Update Cloud Run Service Ingress 
# do this manually as Cloud Run isn't managed by Terraform
# resource "google_cloud_run_service" "default" {
#   name     = "cloud-run-service"
#   location = var.region
#   project  = var.project_id

#   template {
#     spec {
#       containers {
#         image = "us-central1-docker.pkg.dev/as-dev-ga4-flattener-320623/cloud-run-source-deploy/cloud-run-service"  # Replace with the actual image being used
#       }
#     }
#   }

#   metadata {
#     annotations = {
#       "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
#     }
#   }
#   # Other configurations...
# }


# # Create IAP OAuth Brand
resource "google_iap_brand" "project_brand" {
  support_email     = var.user_email
  application_title = "demo"
}

# # Create IAP OAuth Client
resource "google_iap_client" "project_client" {
  display_name = "iap-demo"
  brand        = google_iap_brand.project_brand.name
}

# # Enable IAP on Backend Service
# resource "google_iap_web_backend_service_iam_member" "member" {
#   project = var.project_id
#   web_backend_service = google_compute_backend_service.backend.name
#   role = "roles/iap.httpsResourceAccessor"
#   member = "user:${var.user_email}"
# }

# IAP Settings
# resource "google_iap_settings" "iap_settings" {
#   project = var.project_id
#   oauth2_client_id = google_iap_client.project_client.client_id
#   oauth2_client_secret = google_iap_client.project_client.secret
# }
/*
│ Error: Invalid resource type
│ 
│   on main.tf line 125, in resource "google_iap_settings" "iap_settings":
│  125: resource "google_iap_settings" "iap_settings" {
│ 
│ The provider hashicorp/google does not support resource type "google_iap_settings".
*/


# output "domain" {
#   value = "${google_compute_global_address.static_ip.address}.nip.io"
# }
