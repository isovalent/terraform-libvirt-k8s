resource "local_file" "kubekey_config" {
  filename = "${path.module}/output/kubekey.yaml"
  content = templatefile("${path.module}/templates/kubekey.yaml", {
    k8s_version        = var.k8s_version
    masters_info_list  = var.masters_info_list
    workers_info_list  = var.workers_info_list
    livirt_host_ip     = var.libvirt_host_ip
    disable_kube_proxy = var.disable_kube_proxy
    kube_service_cidrs = var.kube_service_cidrs
    kube_pods_cidrs    = var.kube_pods_cidrs
    enable_ipv6       = var.enable_ipv6
  })
}

resource "local_file" "k8s_install_script" {
  filename = "${path.module}/output/k8s-install.sh"
  content = templatefile("${path.module}/templates/k8s-install.sh", {
    all_nodes_info_json = jsonencode(local.all_nodes_info)
  })
}
resource "null_resource" "testbox_install_k8s" {
  depends_on = [
    libvirt_domain.masters,
    libvirt_domain.workers
  ]
  connection {
    host        = var.testbox_info.public_ip
    user        = var.testbox_info.username
    port        = var.testbox_info.public_port
    private_key = var.testbox_info.private_key
    timeout     = "5m"
    type        = "ssh"
  }

  provisioner "file" {
    source      = local_file.kubekey_config.filename
    destination = "/home/${var.testbox_info.username}/kubekey.yaml"
  }

  provisioner "file" {
    source      = local_file.k8s_install_script.filename
    destination = "/tmp/k8s-install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-install.sh",
      "/tmp/k8s-install.sh"
    ]
  }

}

data "remote_file" "kubeconfig" {
  depends_on = [
    null_resource.testbox_install_k8s,
  ]

  conn {
    host        = var.testbox_info.public_ip
    user        = var.testbox_info.username
    port        = var.testbox_info.public_port
    private_key = var.testbox_info.private_key
  }
  path = "/home/${var.testbox_info.username}/kubekey/config-cluster-config"
}

resource "local_file" "kubeconfig" {
  content  = replace(data.remote_file.kubeconfig.content, "/https:\\/\\/[^:]+:/", "https://${var.libvirt_host_ip}:")
  filename = "${abspath(path.module)}/output/k8s_kubeconfig"
}


