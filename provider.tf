
provider "libvirt" {
  uri = "qemu+ssh://root@${var.libvirt_host_ip}:22/system?sshauth=privkey&known_hosts_verify=ignore&keyfile=${var.libvirt_root_private_key_path}"
}

