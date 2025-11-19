output "path_to_kubeconfig_file" {
  value = local_file.kubeconfig.filename

}

output "k8s_api_server_ip" {
  value = var.libvirt_host_ip

}