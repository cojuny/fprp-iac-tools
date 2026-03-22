terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

#########################################
# Base Image
#########################################
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-24.04-base.qcow2"
  pool   = "default"
  source = "/var/lib/libvirt/images/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

#########################################
# VM Definitions 
#########################################
locals {
  vms = {
    reverse-proxy = {
      ip     = "192.168.100.200"
      memory = 1024
      vcpu   = 1
      disk   = 5
    }
    mariadb = {
      ip     = "192.168.100.201"
      memory = 2048
      vcpu   = 1
      disk   = 20
    }
    kafka = {
      ip     = "192.168.100.202"
      memory = 2048
      vcpu   = 2
      disk   = 20
    }
    nexus = {
      ip     = "192.168.100.203"
      memory = 4096
      vcpu   = 2
      disk   = 50
    }
  }
}

#########################################
# Per-VM Disk
#########################################
resource "libvirt_volume" "vm_disk" {
  for_each = local.vms

  name           = "${each.key}.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = each.value.disk * 1024 * 1024 * 1024
}

#########################################
# Cloud-init per VM
#########################################
resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each = local.vms

  name = "${each.key}-cloudinit.iso"
  pool = "default"

  user_data = templatefile("${path.module}/cloud-init.tpl", {
    hostname = each.key
  })

  meta_data = templatefile("${path.module}/meta-data.tpl", {
    hostname = each.key
  })

  network_config = templatefile("${path.module}/network-config.tpl", {
    ip = each.value.ip
  })
}

#########################################
# VM Definition
#########################################
resource "libvirt_domain" "vm" {
  for_each = local.vms

  name   = each.key
  memory = each.value.memory
  vcpu   = each.value.vcpu

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit[each.key].id

  network_interface {
    bridge = "br0"
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
  }
}