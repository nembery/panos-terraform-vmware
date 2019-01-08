variable vsphere_user {
  default = "user"
  description = "VSphere User"
  type = "string"
}

variable vsphere_password {
  default = "nowaysir"
  description = "Password for vSphere user"
  type = "string"
}

variable vsphere_server {
  default = "10.10.10.10"
  description = "IP or FQDN for vSphere server"
  type = "string"
}

variable vcenter_datacenter {
  default = "dc1"
  description = "Name of the Datacenter"
  type = "string"
}

variable vcenter_datastore {
  default = "datastore1"
  description = "Name of the Datastore"
  type = "string"
}

variable vcenter_resoource_pool {
  default = "rs1"
  description = "Name of the Resource Pool"
  type = "string"
}

variable panos_image {
  default = "/base_images/PA-VM-300-ESX-8.1.0.vmdk"
}

variable vm_host_name {
  default = "panos-01"
  description = "name of vm to launch"
  type = "string"
}

variable bootstrap_image {
  default = "/var/tmp/panos-bootstrap.iso"
  description = "local path to an ISO image used for bootstraping the VM-Series"
  type = "string"
}

variable panos_template_vm {
  default = "PA-VM-ESX-8.1.0"
  description = "VM Instance to clone from"
  type = "string"
}