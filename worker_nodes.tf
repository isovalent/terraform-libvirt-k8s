resource "libvirt_volume" "workers_base" {
  name   = "workers-base"
  source = local.nodes_os_image_url
  pool   = var.libvirt_pool_name
  format = "qcow2"
}

resource "libvirt_volume" "workers" {
  count          = length(var.workers_info_list)
  base_volume_id = libvirt_volume.workers_base.id
  format         = "qcow2"
  name           = "workers${count.index}-root-volume.qcow2"
  size           = 10000000000
  pool           = var.libvirt_pool_name
}


resource "libvirt_cloudinit_disk" "workers" {
  count = length(var.workers_info_list)
  name  = "workers${count.index}.iso"
  pool  = var.libvirt_pool_name
  network_config = templatefile("${path.module}/templates/workers-network-data.yaml", {
  })
  user_data = templatefile("${path.module}/templates/workers-user-data.yaml", {
    worker_name = "workers${count.index}"
    public_ssh_keys = jsonencode([
      var.testbox_info.public_key
    ])
  })
}

resource "libvirt_domain" "workers" {
  count     = length(var.workers_info_list)
  autostart = true
  cloudinit = libvirt_cloudinit_disk.workers[count.index].id
  memory    = 4096
  name      = "workers${count.index}"
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
    volume_id = libvirt_volume.workers[count.index].id
  }


  network_interface {
    network_id     = var.libvirt_private_network_id
    wait_for_lease = false
    mac            = var.workers_info_list[count.index].mac
  }
}

