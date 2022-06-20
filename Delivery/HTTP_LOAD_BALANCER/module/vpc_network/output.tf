output "vpc_network" {
    value = google_compute_network.test.name
}

output "vpc_subnet" {
    value = google_compute_subnetwork.test_subnet.name
}

output "proxy_subnet" {
    value = google_compute_subnetwork.proxy_subnet.name
}

output "firewall_http" {
    value = google_compute_firewall.http_firewall.name 
}

output "firewall_ssh" {
    value = google_compute_firewall.ssh-rule.name 
}

output "healthcheck_firewall" {
    value = google_compute_firewall.fw-iap.name 
}