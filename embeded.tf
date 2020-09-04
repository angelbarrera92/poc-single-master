module "embeded" {
  source = "./modules/aws-k8s-kubeadm"

  region = data.aws_region.current.name

  cluster_name    = "embeded"
  cluster_version = "1.19.0"

  #master_backup_ami = "ami-"

  worker_count = 2

  public_subnet_id  = "subnet-04ba8fda7f4638651"
  private_subnet_id = "subnet-0d59b2ce4a7691c57"

}

output "embeded_tls_private_key" {
  sensitive   = true
  description = "Private RSA Key to log into the control plane node"
  value       = module.embeded.tls_private_key
}

output "embeded_master_public_ip" {
  description = "Public IP where control plane is exposed"
  value       = module.embeded.master_public_ip
}

output "embeded_worker_private_ip" {
  description = "Worker nodes private ip list"
  value       = module.embeded.worker_private_ip
}

