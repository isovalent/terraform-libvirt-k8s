terraform {
  required_version = ">=1.6.5"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }

    remote = {
      source  = "tenstad/remote"
      version = "0.2.1"
    }
  }
}

