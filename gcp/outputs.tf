output "kubernetes_loadbalancer_ip" {
  value = "${google_compute_address.kubernetes.address}"
}
