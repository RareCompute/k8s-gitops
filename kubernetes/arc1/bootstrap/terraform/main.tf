data "sops_file" "proxmox_secrets" {
  source_file = "secret.sops.yaml"
}

provider "sops" {}

provider "proxmox" {
  pm_api_url          = "https://10.0.10.120:8006/api2/json"
  pm_tls_insecure     = true
  pm_user             = data.sops_file.global_secrets.data["pm_user"]
  pm_password         = data.sops_file.global_secrets.data["pm_password"]
  pm_parallel         = 2
}

resource "proxmox_vm_qemu" "talos_controller" {
  count = length(var.controller_hostname)
  name  = var.controller_hostname[count.index]

  target_node = var.proxmox_host
  vmid        = var.controler_vmid + count.index

  agent    = 1
  os_type  = "linux"
  cores    = 3
  sockets  = 2
  cpu_type = "host"
  memory   = 3584
  balloon  = 0
  scsihw   = "virtio-scsi-single"
  vm_state = "running"
  onboot   = true
  boot     = "order=net0;ide0"
  startup  = "order=100"

  disks {
    scsi {
      scsi0 {
        disk {
          size       = "128G"
          storage    = "local-nvme"
          asyncio    = "native"
          discard    = true
          iothread   = true
          emulatessd = true
          backup     = true
        }
      }
    }
    ide {
      ide0  {
        cdrom {
          iso = "local:iso/v1.8.3-controller-nocloud-amd64.iso"
        }
      }
    }
  }
  network {
    id      = 0
    model   = "virtio"
    bridge  = "vmbr0"
    mtu     = 1
    macaddr = var.controller_mac[count.index]
  }
  serial {
    id = 0
  }
}

# TODO: Add PCI devices
resource "proxmox_vm_qemu" "talos_worker" {
  count = length(var.worker_hostname)
  name  = var.worker_hostname[count.index]

  target_node = var.proxmox_host
  vmid        = var.worker_vmid + count.index

  agent    = 1
  os_type  = "linux"
  cores    = 115
  sockets  = 2
  cpu_type = "host"
  balloon  = 0
  memory   = 215040
  scsihw   = "virtio-scsi-single"
  scsihw   = "virtio-scsi-single"
  vm_state = "running"
  onboot   = true
  boot     = "order=net0;ide0"
  startup  = "order=101,up=60"

  disks {
    scsi {
      scsi0 {
        disk {
          size       = "128G"
          storage    = "local-nvme"
          asyncio    = "native"
          discard    = true
          iothread   = true
          emulatessd = true
          backup     = true
        }
      }
      scsi1 {
        disk {
          size       = "3200G"
          storage    = "local-nvme"
          asyncio    = "native"
          discard    = true
          iothread   = true
          emulatessd = true
        }
      }
    }
    ide {
      ide0  {
        cdrom {
          iso = "local:iso/v1.8.3-nocloud-amd64.iso"
        }
      }
    }
  }
  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    mtu      = 1
    macaddr  = var.worker_mac[count.index]
  }
  serial {
    id = 0
  }
}
