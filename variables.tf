variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "us-central1"
}

variable "gcp_zone" {
  type    = string
  default = "us-central1-a"
}

variable "gcp_prefix" {
  type    = string
  default = "Free tier"
}

variable "gcp_website_image" {
  type = string
}
