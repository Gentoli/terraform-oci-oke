# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "utilities" {
  count  = local.cluster_enabled && local.operator_enabled ? 1 : 0
  source = "./modules/utilities"
  region = var.region

  # Cluster
  await_node_readiness = var.await_node_readiness
  expected_node_count  = local.worker_count_expected
  worker_pools         = one(module.workers[*].worker_pools)

  # Bastion/operator connection
  ssh_private_key = sensitive(local.ssh_private_key)
  bastion_host    = local.bastion_public_ip
  bastion_user    = var.bastion_user
  operator_host   = local.operator_private_ip
  operator_user   = var.operator_user

  # OCIR
  ocir_email_address    = var.ocir_email_address
  ocir_secret_id        = var.ocir_secret_id
  ocir_secret_name      = var.ocir_secret_name
  ocir_secret_namespace = var.ocir_secret_namespace
  ocir_username         = var.ocir_username

  # Worker pool draining
  expected_drain_count           = local.worker_drain_expected
  worker_drain_delete_local_data = var.worker_drain_delete_local_data
  worker_drain_ignore_daemonsets = var.worker_drain_ignore_daemonsets
  worker_drain_timeout_seconds   = var.worker_drain_timeout_seconds
}

#fss
module "storage" {
  source = "./modules/storage"

  # general oci parameters
  tenancy_id          = local.tenancy_id
  compartment_id      = local.compartment_id
  availability_domain = var.availability_domains["fss"]
  label_prefix        = var.label_prefix

  # FSS network information
  subnets      = var.subnets
  assign_dns   = var.assign_dns
  vcn_id       = local.vcn_id
  nat_route_id = local.nat_route_id

  fss_mount_path = var.fss_mount_path

  # Export set configuration
  max_fs_stat_bytes = var.max_fs_stat_bytes
  max_fs_stat_files = var.max_fs_stat_files

  providers = {
    oci.home = oci.home
  }

  count = var.create_fss == true ? 1 : 0

}

#fss
variable "create_fss" {
  description = "Whether to enable provisioning for FSS"
  default     = false
  type        = bool
}

# fss mount path
variable "fss_mount_path" {
  description = "FSS mount path to be associated"
  default     = "/oke_fss"
  type        = string
}

# Controls the maximum tbytes, fbytes, and abytes, values reported by NFS FSSTAT calls through any associated mount targets.
variable "max_fs_stat_bytes" {
  description = "Maximum tbytes, fbytes, and abytes, values reported by NFS FSSTAT calls through any associated mount targets"
  default     = 23843202333
  type        = number
}

# Controls the maximum tfiles, ffiles, and afiles values reported by NFS FSSTAT calls through any associated mount targets.
variable "max_fs_stat_files" {
  description = "Maximum tfiles, ffiles, and afiles values reported by NFS FSSTAT"
  default     = 223442
  type        = number
}
