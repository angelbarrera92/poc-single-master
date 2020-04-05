module "embeded" {
  source = "./modules/aws-k8s-kubeadm"

  region = data.aws_region.current.name

  cluster_name    = "embeded"
  cluster_version = "1.16.8"

  #master_backup_ami = "ami-"

  worker_count = 2

  public_subnet_id  = "subnet-3253677a"
  private_subnet_id = "subnet-d9c4e1bf"

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

