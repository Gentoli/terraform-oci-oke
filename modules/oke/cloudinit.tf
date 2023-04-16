
# cloud-init for workers
data "cloudinit_config" "worker" {
  for_each = merge(var.node_pools, var.autoscaler_pools)

  gzip          = false
  base64_encode = true

  part {
    filename     = "worker.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/cloudinit/worker.template.sh",
      {
        worker_timezone = var.node_pool_timezone
        extra_init_args = lookup(each.value, "extra_init_args", null) == null ? "" : " ${each.value.extra_init_args}"
      }
    )
  }

}

