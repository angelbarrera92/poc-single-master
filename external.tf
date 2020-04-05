module "external" {
  source = "./modules/aws-k8s-kubeadm"

  region = data.aws_region.current.name

  cluster_name    = "external"
  cluster_version = "1.16.8"

  #master_backup_ami = "ami-"

  worker_count = 2
  external_db  = true

  public_subnet_id  = "subnet-3253677a"
  private_subnet_id = "subnet-d9c4e1bf"

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
