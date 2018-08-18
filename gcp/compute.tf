resource "google_compute_instance" "controller" {
  count          = 3
  name           = "${format("controller-%d", count.index)}"
  machine_type   = "n1-standard-1"
  zone           = "${element(var.zones, count.index)}"
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size  = "200"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.kubernetes.self_link}"
    address    = "${format("10.240.0.1%d", count.index)}"

    access_config {
    }
  }

  service_account {
    scopes = [
      "compute-rw", "storage-ro", "service-management", "service-control",
      "logging-write", "monitoring"
    ]
  }

  tags = ["kubernetes", "controller"]
}

resource "google_compute_instance" "worker" {
  count          = 3
  name           = "${format("worker-%d", count.index)}"
  machine_type   = "n1-standard-1"
  zone           = "${element(var.zones, count.index)}"
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size  = "200"
    }
  }

  metadata {
    pod-cidr = "${format("10.200.%d.0/24", count.index)}"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.kubernetes.self_link}"
    address    = "${format("10.240.0.2%d", count.index)}"

    access_config {
    }
  }

  service_account {
    scopes = [
      "compute-rw", "storage-ro", "service-management", "service-control",
      "logging-write", "monitoring"
    ]
  }

  tags = ["kubernetes", "worker"]
}
