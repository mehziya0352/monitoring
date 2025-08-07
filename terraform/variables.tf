variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "The region to deploy to"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "The zone to deploy to"
}
