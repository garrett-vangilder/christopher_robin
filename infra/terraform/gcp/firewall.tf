resource "google_compute_firewall" "fw-flask" {
  count = var.server_count  
  name    = "fw-flask-${count.index}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
