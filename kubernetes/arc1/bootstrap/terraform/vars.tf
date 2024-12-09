variable "proxmox_host" {
  description = "Name of the proxmost host"
  type        = string
  default     = "proxmox"
}

variable "controller_hostname" {
  description = "Controller VM hostnames"
  type        = list(string)
  default     = ["n1"]
}

variable "controller_vmid" {
  description = "Controller VM starting ID"
  type        = number
  default     = 100
}

variable "controller_mac" {
  description = "Controller VM Mac Addresses"
  type        = list(string)
  default     = ["BC:24:11:0B:33:A7"]
}

variable "worker_hostname" {
  description = "Worker VM hostnames"
  type        = list(string)
  default     = ["n2"]
}

variable "worker_vmid" {
  description = "Worker VM start ID"
  type        = number
  default     = 101
}

variable "worker_mac" {
  description = "Worker VM Mac Addresses"
  type        = list(string)
  default     = ["BC:24:11:F8:F6:E3"]
}
