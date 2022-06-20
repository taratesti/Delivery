output "vpc1" {
    value = google_compute_network.demo.name
}

output "vpc2" {
    value = google_compute_network.vpc2.name
}
