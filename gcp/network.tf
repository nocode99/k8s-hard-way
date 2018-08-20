resource "google_compute_network" "kubernetes" {
  name                    = "kubernetes"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kubernetes" {
  name          = "kubernetes"
  ip_cidr_range = "10.240.0.0/24"
  region        = "us-east1"
  network       = "${google_compute_network.kubernetes.self_link}"
}

resource "google_compute_firewall" "kubernetes_internal" {
  name    = "kubernetes-internal"
  network = "${google_compute_network.kubernetes.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["10.200.0.0/24", "10.240.0.0/16"]
}

resource "google_compute_firewall" "kubernetes_external" {
  name    = "kubernetes-external"
  network = "${google_compute_network.kubernetes.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "kubernetes_healthcheck_loadbalancer" {
  name    = "kubernetes-loadbalancer-healthcheck"
  network = "${google_compute_network.kubernetes.name}"

  allow {
    protocol = "tcp"
  }

  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
}

resource "google_compute_address" "kubernetes" {
  name         = "kubernetes"
  address_type = "EXTERNAL"
}

resource "google_compute_route" "kubernetes_worker" {
  count       = 3
  name        = "${format(
    "kubernetes-worker-routes-10-200-0-%d",
    count.index
  )}"
  network     = "${google_compute_network.kubernetes.name}"
  next_hop_ip = "${format("10.240.0.2%d", count.index)}"
  dest_range  = "${format("10.200.%d.0/24", count.index)}"

}
