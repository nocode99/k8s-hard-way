resource "google_compute_http_health_check" "kubernetes" {
  name         = "kubernetes-health-check"
  host         = "kubernetes.default.svc.cluster.local"
  request_path = "/healthz"
}

resource "google_compute_target_pool" "kubernetes" {
  name          = "kubernetes"
  instances     = [
    "us-east1-b/controller-0",
    "us-east1-c/controller-1",
    "us-east1-d/controller-2"
  ]
  health_checks = ["${google_compute_http_health_check.kubernetes.name}"]
}

resource "google_compute_forwarding_rule" "kubernetes" {
  name       = "kubernetes-forwarding-rules"
  target     = "${google_compute_target_pool.kubernetes.self_link}"
  port_range = "6443"
  ip_address = "${google_compute_address.kubernetes.address}"
}
