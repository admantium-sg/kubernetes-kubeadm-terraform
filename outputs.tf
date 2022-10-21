output "controller_ip" {
  value = hcloud_server.controller["controller"].ipv4_address
}
