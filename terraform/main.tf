provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance_template" "telegraf_template" {
  name_prefix = "telegraf-template-"
  machine_type = "e2-medium"

  disk {
    boot  = true
    auto_delete = true
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/templates/startup-script.sh")

  tags = ["telegraf-vm"]
}

resource "google_compute_health_check" "http_health_check" {
  name               = "http-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 80
  }
}

resource "google_compute_instance_group_manager" "telegraf_mig" {
  name               = "telegraf-mig"
  base_instance_name = "telegraf"
  region             = var.region
  version {
    instance_template = google_compute_instance_template.telegraf_template.self_link
  }
  target_size = 1

  auto_healing_policies {
    health_check      = google_compute_health_check.http_health_check.self_link
    initial_delay_sec = 60
  }
}

resource "google_compute_autoscaler" "telegraf_autoscaler" {
  name   = "telegraf-autoscaler"
  region = var.region
  target = google_compute_instance_group_manager.telegraf_mig.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}

resource "google_compute_global_address" "default" {
  name = "load-balancer-ip"
}

resource "google_compute_backend_service" "default" {
  name                            = "backend-service"
  port_name                       = "http"
  protocol                        = "HTTP"
  timeout_sec                     = 10
  enable_cdn                      = false
  health_checks                   = [google_compute_health_check.http_health_check.id]
  backend {
    group = google_compute_instance_group_manager.telegraf_mig.instance_group
  }
}

resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_target_http_proxy" "default" {
  name   = "http-proxy"
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "http-content-rule"
  ip_address = google_compute_global_address.default.address
  port_range = "80"
  target     = google_compute_target_http_proxy.default.self_link
