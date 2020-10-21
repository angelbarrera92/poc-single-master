variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID where control-plane will run"
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet ID where worker nodes will run"
}

variable "region" {
  type        = string
  description = "AWS Region where cluster will run"
}

variable "cluster_name" {
  type        = string
  description = "Unique identifier of the cluster. Used as system user to log into the instances"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version to deploy"
}

variable "trusted_cidrs" {
  type        = list
  description = "List of allowed cidrs to access the control-plane/cluster"
  default     = ["0.0.0.0/0"]
}

variable "external_db" {
  type        = bool
  description = "Use an external DB"
  default     = false
}

variable "rds_instance_type" {
  type        = string
  description = "In case you select external_db this variable contains the rds instance type"
  default     = "db.m5.large"
}

variable "master_instance_type" {
  type        = string
  description = "Instance type used to run Kubernetes control-plane. Choose one: m5.large, m5.xlarge, m5.2xlarge, m5.4xlarge"
  default     = "m5.large"
}

variable "master_backup_ami" {
  type        = string
  description = "If you want to restore an Kubernetes Master from a previous state specify the AMI ID"
  default     = ""
}

variable "worker_instance_type" {
  type        = string
  description = "Instance type used to run Kubernetes worker. Choose one: m5.large, m5.xlarge, m5.2xlarge, m5.4xlarge"
  default     = "m5.xlarge"
}

variable "worker_count" {
  type        = number
  description = "Number of workers nodes to deploy"
  default     = 2
}

variable "pod_network_cidr" {
  type        = string
  description = "Specify range of IP addresses for the pod network. Default to calico default value"
  default     = "192.168.0.0/16"
}

variable "svc_network_cidr" {
  type        = string
  description = "Specify range of IP addresses for the service network. Default to kubeadm default value"
  default     = "10.96.0.0/12"
}

locals {
  # https://cloud-images.ubuntu.com/locator/ec2/
  # filter: 18.04 LTS eu- ebs-ssd 2020
  ubuntu_amis = {
    "eu-west-1" : "ami-07042e91d04b1c30d"
    "eu-west-2" : "ami-04cc79dd5df3bffca"
    "eu-central-1" : "ami-0718a1ae90971ce4d"
    "eu-west-3" : "ami-0c367ebddcf279dc6"
    "eu-north-1" : "ami-0e850e0e9c20d9deb"
  }
  # https://aws.amazon.com/ec2/pricing/on-demand/
  # Just split by ~2 the ondemenad price.
  sport_prices = {
    "m4.large" : "0.05"
    "m4.xlarge" : "0.10"
    "m4.2xlarge" : "0.20"
    "m4.4xlarge" : "0.40"
    "m5.large" : "0.07"
    "m5.xlarge" : "0.12"
    "m5.2xlarge" : "0.20"
    "m5.4xlarge" : "0.40"
  }
}
