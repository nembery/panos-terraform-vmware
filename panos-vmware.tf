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

variable panos_image {
  default = "/var/tmp/PA-VM-ESX-8.1.0-disk1.vmdk"
}

variable vm_host_name {
  default = "panos-01"
  description = "name of vm to launch"
  type = "string"
}

variable bootstrap_image {
  default = '/var/tmp/panos-bootstrap.iso'
  description = 'local path to an ISO image used for bootstraping the VM-Series'
  type = 'string'
}

resource "vsphere_file" "panos-base-image" {
  datacenter = "dc1"
  datastore = "datastore1"
  source_file = "${var.panos_image}"
  destination_file = "/base_images/panos-81-base.vmdk"
}

resource "vsphere_file" "panos-bootstrap-image" {
  datacenter = "dc1"
  datastore = "datastore1"
  source_file = "${var.bootstrap_image}"
  destination_file = "/bootstrap_images/${var.vm_host_name}-bootstrap.iso"
}

resource "vsphere_file" "vsphere_panos_image" {
  source_datacenter = "dc1"
  datacenter = "dc1"
  source_datastore = "datastore1"
  datastore = "datastore1"
  source_file = "/base_images/panos-81-base.vmdk"
  destination_file = "/instance_images/${var.vm_host_name}-disk1.vmdk"
}

provider "vsphere" {
  user = "${var.vsphere_user}"
  password = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "dc1"
}

data "vsphere_datastore" "datastore" {
  name = "datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name = "cluster1/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name = "${var.vm_host_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 4
  memory = 8192
  guest_id = "centos64Guest"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label = "disk0"
    attach = true
    path = "/instance_images/${var.vm_host_name}-disk1.vmdk"
    datastore_id = "${data.vsphere_datastore.datastore.id}"
  }

  cdrom {
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    path = "/bootstrap_images/${var.vm_host_name}-bootstrap.iso"
  }
}