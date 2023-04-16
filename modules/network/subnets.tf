# Copyright (c) 2017, 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_subnet" "cp" {
  cidr_block                 = local.cp_subnet
  compartment_id             = var.compartment_id
  display_name               = local.subnet_display_names["cp"]
  dns_label                  = local.subnet_dns_label["cp"]
  prohibit_public_ip_on_vnic = var.control_plane_type == "private" ? true : false
  route_table_id             = var.control_plane_type == "private" ? var.nat_route_id : var.ig_route_id
  security_list_ids          = [oci_core_security_list.control_plane_seclist.id]
  vcn_id                     = var.vcn_id

  lifecycle {
    ignore_changes = [dns_label]
  }
}

resource "oci_core_subnet" "workers" {
  cidr_block                 = local.workers_subnet
  compartment_id             = var.compartment_id
  display_name               = local.subnet_display_names["workers"]
  dns_label                  = local.subnet_dns_label["workers"]
  prohibit_public_ip_on_vnic = var.worker_type == "private" ? true : false
  route_table_id             = var.worker_type == "private" ? var.nat_route_id : var.ig_route_id
  vcn_id                     = var.vcn_id

  lifecycle {
    ignore_changes = [dns_label]
  }
}

resource "oci_core_subnet" "pods" {
  cidr_block                 = local.pods_subnet
  compartment_id             = var.compartment_id
  display_name               = local.subnet_display_names["pods"]
  dns_label                  = local.subnet_dns_label["pods"]
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.nat_route_id
  vcn_id                     = var.vcn_id

  lifecycle {
    ignore_changes = [dns_label]
  }

  count = var.cni_type == "npn" ? 1 : 0
}

resource "oci_core_subnet" "int_lb" {
  cidr_block                 = local.int_lb_subnet
  compartment_id             = var.compartment_id
  display_name               = local.subnet_display_names["int_lb"]
  dns_label                  = local.subnet_dns_label["int_lb"]
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.nat_route_id
  vcn_id                     = var.vcn_id

  lifecycle {
    ignore_changes = [dns_label]
  }

  count = var.load_balancers == "internal" || var.load_balancers == "both" ? 1 : 0
}

resource "oci_core_subnet" "pub_lb" {
  cidr_block                 = local.pub_lb_subnet
  compartment_id             = var.compartment_id
  display_name               = local.subnet_display_names["pub_lb"]
  dns_label                  = local.subnet_dns_label["pub_lb"]
  prohibit_public_ip_on_vnic = false
  route_table_id             = var.ig_route_id
  vcn_id                     = var.vcn_id

  lifecycle {
    ignore_changes = [dns_label]
  }

  count = var.load_balancers == "public" || var.load_balancers == "both" ? 1 : 0
}
