provider "google" {
  credentials = file("${path.module}/gcloud-service.json")
  project     = var.gcp_project
  region      = var.gcp_region
}

# Create boot disk image
data "google_compute_image" "ss_compute_image" {
  family  = "cos-stable"
  project = "cos-cloud"
}

# Create a boot disk
resource "google_compute_disk" "ss_compute_disk" {
  name  = "${replace(lower(var.gcp_prefix), " ", "-")}-boot-disk"
  zone  = var.gcp_zone
  size  = 10
  type  = "pd-standard"
  image = data.google_compute_image.ss_compute_image.self_link
}

# Create a public static ip
resource "google_compute_address" "ss_google_compute_address" {
  name         = "${replace(lower(var.gcp_prefix), " ", "-")}-public-ip"
  address_type = "EXTERNAL"
  region       = var.gcp_region
}

# Create a separate network
resource "google_compute_network" "ss_google_compute_network" {
  name = "${replace(lower(var.gcp_prefix), " ", "-")}-network"
}

# Create a firewall rule to allow port 80 (http)
resource "google_compute_firewall" "ss_google_compute_firewall_allow_http" {
  name    = "${replace(lower(var.gcp_prefix), " ", "-")}-allow-http"
  network = google_compute_network.ss_google_compute_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["http-server"]
}

# Create a firewall rule to allow port 443 (https)
resource "google_compute_firewall" "ss_google_compute_firewall_allow_https" {
  name    = "${replace(lower(var.gcp_prefix), " ", "-")}-allow-https"
  network = google_compute_network.ss_google_compute_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

# # Uncomment this section to enable SSH access
# # Create a firewall rule to allow port 22 (ssh)
# resource "google_compute_firewall" "ss_google_compute_firewall_allow_ssh" {
#   name    = "${replace(lower(var.gcp_prefix), " ", "-")}-allow-ssh"
#   network = google_compute_network.ss_google_compute_network.name

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   priority = 65534

#   source_ranges = ["0.0.0.0/0"]
# }

# Create VM
resource "google_compute_instance" "ss_google_compute_instance" {
  name         = "${replace(lower(var.gcp_prefix), " ", "-")}-vm"
  machine_type = "f1-micro"
  zone         = var.gcp_zone

  boot_disk {
    source = google_compute_disk.ss_compute_disk.self_link
  }

  tags = ["http-server", "https-server"]

  metadata = {
    google-logging-enabled = true
    gce-container-declaration = yamlencode({
      spec = {
        containers = [
          {
            image = var.gcp_website_image
          }
        ]
        restartPolicy = "Always"
      }
    })
  }

  labels = {
    container-vm = data.google_compute_image.ss_compute_image.name
  }

  network_interface {
    network = google_compute_network.ss_google_compute_network.self_link
    access_config {
      nat_ip = google_compute_address.ss_google_compute_address.address
    }
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

# Output the created public ip
output "public_ip" {
  value = google_compute_address.ss_google_compute_address.address
}
