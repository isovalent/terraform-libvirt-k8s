resource "libvirt_volume" "masters_base" {
  name   = "masters-base"
  source = local.nodes_os_image_url
  pool   = var.libvirt_pool_name
  format = "qcow2"
}

resource "libvirt_volume" "masters" {
  count          = length(var.masters_info_list)
  base_volume_id = libvirt_volume.masters_base.id
  format         = "qcow2"
  name           = "masters${count.index}-root-volume.qcow2"
  size           = 10000000000
  pool           = var.libvirt_pool_name
}


resource "libvirt_cloudinit_disk" "masters" {
  count          = length(var.masters_info_list)
  name           = "masters${count.index}.iso"
  pool           = var.libvirt_pool_name
  network_config = templatefile("${path.module}/templates/masters-network-data.yaml", {
    ipv6_address = var.masters_info_list[count.index].ipv6
  })
  user_data = templatefile("${path.module}/templates/masters-user-data.yaml", {
    master_name = "masters${count.index}"
    public_ssh_keys = jsonencode([
      var.testbox_info.public_key
    ])
  })
}

resource "libvirt_domain" "masters" {
  count     = length(var.masters_info_list)
  autostart = true
  cloudinit = libvirt_cloudinit_disk.masters[count.index].id
  memory    = 4096
  name      = "masters${count.index}"
  vcpu      = 2
  cpu {
    mode = "host-passthrough"

  }
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  graphics {
    type        = "vnc"
    listen_type = "address"
  }
  disk {
    volume_id = libvirt_volume.masters[count.index].id
  }

  network_interface {
    network_id     = var.libvirt_private_network_id
    wait_for_lease = false
    mac            = var.masters_info_list[count.index].mac
  }
}
