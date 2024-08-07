packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.5"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}
# Variable Definitions
variable "proxmox_host" { type = string }
variable "proxmox_api_user" { type = string }
variable "proxmox_api_password" { type = string }

variable "template_name" { type = string }
variable "vm_id" { type = string }
variable "proxmox_node" { type = string }
#variable "cpu_type" { type = string }
#variable "machine" { type = string }
variable "cores" { type = string }
variable "sockets" { type = string }
variable "memory" { type = string }
variable "os" { type = string }
variable "bridge" { type = string }
variable "disk_type" { type = string }
variable "disk_format" { type = string }
variable "disk_size" { type = string }
variable "datastore" { type = string }
#variable "datastore_type" { type = string }
#variable "disk_cache_mode" { type = string }
variable "cloud_init_storage_pool" { type = string }
variable "iso" { type = string }
variable "scsi_controller" { type = string }

variable "ssh_timeout" { type = string }
variable "ssh_username" { type = string }
variable "ssh_password" { type = string }
variable "http_directory" { type = string }
variable "http_bind_address" { type = string }

variable "boot_command" { type = list(string) }
variable "playbook_file" { type = string }

source "proxmox-iso" "ubuntu-server-jammy" {

  # Proxmox Connection Settings
  proxmox_url              = "https://${var.proxmox_host}:8006/api2/json"
  insecure_skip_tls_verify = true
  username                 = var.proxmox_api_user
  password                 = var.proxmox_api_password

  # VM Configurations
  #vm_name    = var.template_name
  vm_name = "ubuntu-server-jammy"
  vm_id      = var.vm_id
  node       = var.proxmox_node
  cores      = var.cores
  cpu_type   = "host"
  machine    = "q35"
  sockets    = var.sockets
  memory     = var.memory
  os         = var.os
  qemu_agent = true

  network_adapters {
    model    = "virtio"
    bridge   = var.bridge
    firewall = "false"
  }

  disks {
    type              = var.disk_type
    format            = var.disk_format
    disk_size         = var.disk_size
    storage_pool      = var.datastore
  }

  # Cloud-init Configurations
  cloud_init              = true
  cloud_init_storage_pool = var.cloud_init_storage_pool

  # Default SCSI Controller Configurations
  scsi_controller = var.scsi_controller

  # SSH Configurations
  ssh_port     = 22
  ssh_timeout  = var.ssh_timeout
  ssh_username = var.ssh_username
  #ssh_password = var.ssh_password
  ssh_private_key_file = "~/.ssh/id_ed25519"

  # Template Configurations
  iso_file             = var.iso
  iso_storage_pool     = "iso"
  unmount_iso          = true
  #template_name        = var.template_name
  #template_description = "${var.template_name}, generated by packer on ${timestamp()}"
  template_description = "Ubuntu Server jammy Image"
  http_directory       = var.http_directory
  #http_bind_address    = var.http_bind_address
  http_port_min        = 8802
  http_port_max        = 8802

  # Boot Configurations
  boot = "c"
  boot_wait    = "5s"
  boot_command = var.boot_command
}

### Base Template ###

build {

  name = "ubuntu-server-jammy"

  sources = ["proxmox-iso.ubuntu-server-jammy"]

  # Provisioner Configurations

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            #"sudo apt -y autoremove --purge",
            #"sudo apt -y clean",
            #"sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }


  # Main playbook depends of vm_type
   provisioner "ansible-local" {
     pause_before            = "10s"
     playbook_dir            = "../playbooks"
     playbook_file           = var.playbook_file
     role_paths              = ["../../ansible-playbooks/roles/"]
     clean_staging_directory = true
     extra_arguments = [
       "--extra-vars", "\"ansible_user=packer ansible_become_password=packer\""
     ]
  }

}
