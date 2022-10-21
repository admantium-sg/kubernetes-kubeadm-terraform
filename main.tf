resource "tls_private_key" "generic-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p .ssh-${terraform.workspace}/
      echo "${tls_private_key.generic-ssh-key.private_key_openssh}" > .ssh-${terraform.workspace}/id_rsa.key
      echo "${tls_private_key.generic-ssh-key.public_key_openssh}" > .ssh-${terraform.workspace}/id_rsa.pub
      chmod 400 .ssh-${terraform.workspace}/id_rsa.key
      chmod 400 .ssh-${terraform.workspace}/id_rsa.key
    EOF
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      rm -rvf .ssh-${terraform.workspace}/
    EOF
  }
}

resource "hcloud_ssh_key" "primary-ssh-key" {
  name       = "hcloud-ssh-key-${terraform.workspace}"
  public_key = tls_private_key.generic-ssh-key.public_key_openssh
}

resource "hcloud_server" "controller" {
  for_each    = toset(lookup(var.server_config.controller_instances, terraform.workspace))
  name        = format("%s-%s", each.key, terraform.workspace)
  server_type = lookup(var.server_config.controller_server_type, terraform.workspace)
  image       = var.linux_image
  location    = "fsn1"
  ssh_keys    = [hcloud_ssh_key.primary-ssh-key.name]
  #firewall_ids = [hcloud_firewall.default-ingress.id]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.generic-ssh-key.private_key_openssh
    host        = self.ipv4_address
  }

  provisioner "remote-exec" {
    scripts = [
      "./bin/01_install.sh",
      "./bin/02_kubeadm_init.sh"
    ]
  }

  provisioner "local-exec" {
    command = <<EOF
      rm -rvf ./bin/03_kubeadm_join.sh
      echo "echo 1 > /proc/sys/net/ipv4/ip_forward" > ./bin/03_kubeadm_join.sh
      ssh root@${self.ipv4_address} -o StrictHostKeyChecking=no -i .ssh-${terraform.workspace}/id_rsa.key "kubeadm token create --print-join-command" >> ./bin/03_kubeadm_join.sh
    EOF
  }
}

resource "hcloud_server" "worker" {
  for_each    = toset(lookup(var.server_config.worker_instances, terraform.workspace))
  name        = format("%s-%s", each.key, terraform.workspace)
  server_type = lookup(var.server_config.worker_server_type, terraform.workspace)
  image       = var.linux_image
  location    = "fsn1"
  ssh_keys    = [hcloud_ssh_key.primary-ssh-key.name]
  #firewall_ids = [hcloud_firewall.default-ingress.id]

  depends_on = [
    hcloud_server.controller
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.generic-ssh-key.private_key_openssh
    host        = self.ipv4_address
  }

  provisioner "remote-exec" {
    scripts = [
      "./bin/01_install.sh",
      "./bin/03_kubeadm_join.sh"
    ]
  }
}

# resource "hcloud_firewall" "default-ingress" {
#   labels = {}
#   name   = "default-ingress"

#   rule {
#     direction = "in"
#     port      = "22"
#     protocol  = "tcp"
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0",
#     ]
#   }

#   rule {
#     direction = "in"
#     port      = "80"
#     protocol  = "tcp"
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0",
#     ]
#   }

#   rule {
#     direction = "in"
#     port      = "443"
#     protocol  = "tcp"
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0",
#     ]
#   }

#   rule {
#     direction = "in"
#     port      = "6443"
#     protocol  = "tcp"
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0",
#     ]
#   }
# }

# resource "hcloud_firewall" "default-egress" {
#   labels = {}
#   name   = "default-egress"

#   rule {
#     direction = "out"
#     port      = "53"
#     protocol  = "tcp"
#     destination_ips = [
#       "0.0.0.0/0",
#       "::/0",
#     ]
#   }

#   rule {
#     direction = "out"
#     port      = "53"
#     protocol  = "udp"
#     destination_ips = [
#       "0.0.0.0/0",
#       "::/0",
#     ]
#   }
# }
