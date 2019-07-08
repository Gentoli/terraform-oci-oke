# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  available_kubernetes_versions = data.oci_containerengine_cluster_option.k8s_cluster_option.kubernetes_versions
  num_kubernetes_versions       = length(local.available_kubernetes_versions)
  kubernetes_version            = var.cluster_kubernetes_version == "LATEST" ? element(sort(local.available_kubernetes_versions), (local.num_kubernetes_versions - 1)) : var.cluster_kubernetes_version
}

data "oci_core_images" "latest_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.node_pool_image_operating_system
  operating_system_version = var.node_pool_image_operating_system_version
  shape                    = var.node_pool_node_shape
  sort_by                  = "TIMECREATED"
}

data "oci_containerengine_cluster_option" "k8s_cluster_option" {
  #Required
  cluster_option_id = "all"
}
