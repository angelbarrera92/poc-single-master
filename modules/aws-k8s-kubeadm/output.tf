output "tls_private_key" {
  sensitive   = true
  description = "Private RSA Key to log into the control plane node"
  value       = tls_private_key.master.private_key_pem
}

output "master_public_ip" {
  description = "Public IP where control plane is exposed"
  value       = aws_eip.master.public_ip
}

output "ssh_command_help" {
  description = "Long command to ssh the control plane"
  value       = "terraform output tls_private_key > cluster.key && chmod 400 cluster.key && ssh -i cluster.key ${var.cluster_name}@${aws_eip.master.public_ip}"
}

output "worker_private_ip" {
  description = "Worker nodes private ip list"
  value       = aws_spot_instance_request.worker.*.private_ip
}
