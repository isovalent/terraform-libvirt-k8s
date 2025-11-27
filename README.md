# Libvirt Kubernetes (k8s) Module

This module deploys Kubernetes master and worker nodes as libvirt VMs. It then uses the `testbox` VM created by the `libvirt-infra` module to run `kubekey` and install a Kubernetes cluster on these nodes.

## Architecture

This module builds upon the infrastructure provisioned by the `libvirt-infra` module and performs the following actions:

1.  **Provisions Kubernetes Nodes**: Creates the specified number of master and worker node VMs using a base Ubuntu cloud image.
2.  **Configures Nodes with Cloud-Init**: Uses cloud-init to set up basic node configuration, including adding the public SSH key from the `testbox` for access.
3.  **Installs Kubernetes using KubeKey**:
    *   Generates a `kubekey` configuration file (`kubekey.yaml`) based on the provided variables.
    *   Copies the configuration and an installation script to the `testbox` VM.
    *   Executes the script on the `testbox` to trigger the `kubekey` installation process across all newly created nodes.
4.  **Retrieves Kubeconfig**: After a successful installation, it retrieves the `kubeconfig` file from the `testbox`, modifies the API server address to point to the libvirt host (as configured by the `libvirt-infra` module's port forwarding), and saves it locally.

## Usage

This module is intended to be used after the `libvirt-infra` module has been successfully applied.

```bash
terraform init
terraform apply
```

Upon successful completion, the `kubeconfig` file for your new cluster will be available in the `output` directory within this module's path.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.6.5 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | 0.7.6 |
| <a name="requirement_remote"></a> [remote](#requirement\_remote) | 0.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | 0.7.6 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_remote"></a> [remote](#provider\_remote) | 0.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [libvirt_cloudinit_disk.masters](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.6/docs/resources/cloudinit_disk) | resource |
| [libvirt_cloudinit_disk.workers](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.6/docs/resources/cloudinit_disk) | resource |
| [libvirt_domain.masters](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.6/docs/resources/domain) | resource |
| [libvirt_domain.workers](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.6/docs/resources/domain) | resource |
| [libvirt_volume.masters](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.6/docs/resources/volume) | resource |
| [libvirt_volume.masters_base](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.6/docs/resources/volume) | resource |
| [libvirt_volume.workers](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.6/docs/resources/volume) | resource |
| [libvirt_volume.workers_base](https://registry.terraform.io/providers/dmacvicar/libvirt/0.7.6/docs/resources/volume) | resource |
| [local_file.k8s_install_script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.kubekey_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.testbox_install_k8s](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [remote_file.kubeconfig](https://registry.terraform.io/providers/tenstad/remote/0.2.1/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disable_kube_proxy"></a> [disable\_kube\_proxy](#input\_disable\_kube\_proxy) | disable kubeproxy | `string` | `"true"` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Enable IPv6 for the Kubernetes cluster. | `bool` | `false` | no |
| <a name="input_image_download_base_url"></a> [image\_download\_base\_url](#input\_image\_download\_base\_url) | the base url of the images | `string` | n/a | yes |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | the version of the k8s | `string` | n/a | yes |
| <a name="input_kube_pods_cidrs"></a> [kube\_pods\_cidrs](#input\_kube\_pods\_cidrs) | CIDRs for Kubernetes pods. | <pre>object({<br/>    ipv4 = string<br/>    ipv6 = string<br/>  })</pre> | <pre>{<br/>  "ipv4": "10.244.0.0/16",<br/>  "ipv6": "fd00:10:244::/104"<br/>}</pre> | no |
| <a name="input_kube_service_cidrs"></a> [kube\_service\_cidrs](#input\_kube\_service\_cidrs) | CIDRs for Kubernetes services. | <pre>object({<br/>    ipv4 = string<br/>    ipv6 = string<br/>  })</pre> | <pre>{<br/>  "ipv4": "10.96.0.0/12",<br/>  "ipv6": "fd00:10:96::/112"<br/>}</pre> | no |
| <a name="input_libvirt_host_ip"></a> [libvirt\_host\_ip](#input\_libvirt\_host\_ip) | The IP address of the libvirt host. | `string` | n/a | yes |
| <a name="input_libvirt_pool_name"></a> [libvirt\_pool\_name](#input\_libvirt\_pool\_name) | The libvirt pool name. | `string` | n/a | yes |
| <a name="input_libvirt_private_network_id"></a> [libvirt\_private\_network\_id](#input\_libvirt\_private\_network\_id) | The libvirt private network id. | `string` | n/a | yes |
| <a name="input_libvirt_root_private_key_path"></a> [libvirt\_root\_private\_key\_path](#input\_libvirt\_root\_private\_key\_path) | The private key path of the libvirt host. | `string` | n/a | yes |
| <a name="input_masters_info_list"></a> [masters\_info\_list](#input\_masters\_info\_list) | The list of master nodes. | <pre>list(object({<br/>    ipv4     = string<br/>    ipv6     = string<br/>    mac      = string<br/>    hostname = string<br/>  }))</pre> | n/a | yes |
| <a name="input_nodes_os_image_name"></a> [nodes\_os\_image\_name](#input\_nodes\_os\_image\_name) | the name of the os image | `string` | `"ubuntu-22.04.3-kernel-5.15.0-92.iso"` | no |
| <a name="input_testbox_info"></a> [testbox\_info](#input\_testbox\_info) | the testbox info | <pre>object({<br/>    public_ip   = string<br/>    username    = string<br/>    public_port = string<br/>    private_key = string<br/>    public_key  = string<br/>  })</pre> | n/a | yes |
| <a name="input_workers_info_list"></a> [workers\_info\_list](#input\_workers\_info\_list) | The list of worker nodes. | <pre>list(object({<br/>    ipv4     = string<br/>    ipv6     = string<br/>    mac      = string<br/>    hostname = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_k8s_api_server_ip"></a> [k8s\_api\_server\_ip](#output\_k8s\_api\_server\_ip) | n/a |
| <a name="output_path_to_kubeconfig_file"></a> [path\_to\_kubeconfig\_file](#output\_path\_to\_kubeconfig\_file) | n/a |
<!-- END_TF_DOCS -->