locals {
  nodes_os_image_url = "${var.image_download_base_url}/${var.nodes_os_image_name}"

  all_nodes_info = concat(
    [for m in var.masters_info_list : { ip = m.ipv4, hostname = m.hostname }],
    [for w in var.workers_info_list : { ip = w.ipv4, hostname = w.hostname }]
  )
}
