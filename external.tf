module "external" {
  source = "./modules/aws-k8s-kubeadm"

  region = data.aws_region.current.name

  cluster_name    = "external"
  cluster_version = "1.19.0"

  external_db  = true

  worker_count = 2

  public_subnet_id  = "subnet-04ba8fda7f4638651"
  private_subnet_id = "subnet-0d59b2ce4a7691c57"

}

output "external_tls_private_key" {
  sensitive   = true
  description = "Private RSA Key to log into the control plane node"
  value       = module.external.tls_private_key
}

output "external_master_public_ip" {
  description = "Public IP where control plane is exposed"
  value       = module.external.master_public_ip
}

output "external_worker_private_ip" {
  description = "Worker nodes private ip list"
  value       = module.external.worker_private_ip
}
