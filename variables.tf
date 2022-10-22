variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "hcloud_location" {
  type    = string
  default = "hel1"
}

variable "hcloud_linux_image" {
  type    = string
  default = "debian-11"
}

variable "server_config" {
  default = ({
    controller_server_type = {
      staging    = "cx21"
      production = "cx31"
    }
    worker_server_type = {
      staging    = "cpx21"
      production = "cpx31"
    }
    controller_instances = {
      staging    = ["controller"]
      production = ["controller"]
    }
    worker_instances = {
      staging    = ["worker1", "worker2"]
      production = ["worker1", "worker2", "worker3", "worker4"]
  } })
}