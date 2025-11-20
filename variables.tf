variable "libvirt_host_ip" {
  description = "The IP address of the libvirt host."
  type        = string
}


variable "libvirt_root_private_key_path" {
  description = "The private key path of the libvirt host."
  type        = string
}

variable "libvirt_pool_name" {
  description = "The libvirt pool name."
  type        = string
}

variable "libvirt_private_network_id" {
  description = "The libvirt private network id."
  type        = string
}

variable "masters_info_list" {
  description = "The list of master nodes."
  type = list(object({
    ipv4     = string
    ipv6     = string
    mac      = string
    hostname = string
  }))
}

variable "workers_info_list" {
  description = "The list of worker nodes."
  type = list(object({
    ipv4     = string
    ipv6     = string
    mac      = string
    hostname = string
  }))
}

variable "image_download_base_url" {
  description = "the base url of the images"
  type        = string
}

variable "nodes_os_image_name" {
  description = "the name of the os image"
  default     = "ubuntu-22.04.3-kernel-5.15.0-92.iso"
  type        = string
}

variable "testbox_info" {
  description = "the testbox info"
  type = object({
    public_ip   = string
    username    = string
    public_port = string
    private_key = string
    public_key  = string
  })
}

variable "k8s_version" {
  description = "the version of the k8s"
  type        = string
}

variable "disable_kube_proxy" {
  description = "disable kubeproxy"
  default     = "true"
  type        = string
}


variable "enable_ipv6" {
  description = "enable ipv6"
  type        = bool
  default     = false
}

variable "k8s_pod_cidr" {
  description = "K8s pod CIDR"
  type = object({
    ipv4 = string
    ipv6 = string
  })
  default = {
    ipv4 = "10.244.0.0/16"
    ipv6 = "fd00:10:244::/48"
  }
}

variable "k8s_service_cidr" {
  description = "K8s service CIDR"
  type = object({
    ipv4 = string
    ipv6 = string
  })
  default = {
    ipv4 = "10.96.0.0/12"
    ipv6 = "fd00:10:96::/112"
  }
}
