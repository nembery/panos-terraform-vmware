provider "vsphere" {
  user = "${var.vsphere_user}"
  password = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

resource "vsphere_file" "panos-bootstrap-image" {
  datacenter = "${var.vcenter_datacenter}"
  datastore = "${var.vcenter_datastore}"
  source_file = "${var.bootstrap_image}"
  destination_file = "/bootstrap_images/${var.vm_host_name}-bootstrap.iso"
  create_directories = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vcenter_datacenter}"
}

data "vsphere_datastore" "datastore" {
  name = "${var.vcenter_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name = "${var.vcenter_resoource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "panos_template" {
  name = "${var.panos_template_vm}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name = "${var.vm_host_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 4
  memory = 8192
  guest_id = "${data.vsphere_virtual_machine.panos_template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.panos_template.scsi_type}"
  wait_for_guest_net_timeout = 0
  wait_for_guest_net_routable = 0

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.panos_template.id}"
  }

  disk {
    label = "disk0"
    size = "${data.vsphere_virtual_machine.panos_template.disks.0.size}"
    eagerly_scrub = "${data.vsphere_virtual_machine.panos_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.panos_template.disks.0.thin_provisioned}"
  }

  cdrom {
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    path = "${vsphere_file.panos-bootstrap-image.destination_file}"
  }
  depends_on = [
    "vsphere_file.panos-bootstrap-image"
  ]
}