resource "aws_security_group" "master" {
  vpc_id      = data.aws_vpc.vpc.id
  name_prefix = "${var.cluster_name}-master"
}

resource "aws_security_group_rule" "master_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.trusted_cidrs
  security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.master.id
}

resource "tls_private_key" "master" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  pgetcd_db_endpoint       = var.external_db == true ? "postgres://pgetcd:${random_string.db_password[0].result}@${aws_db_instance.db[0].endpoint}/pgetcd" : ""
  template_file            = var.external_db == true ? "master-external-db.tpl.yaml" : "master.tpl.yaml"
  master_private_static_ip = cidrhost(data.aws_subnet.public.cidr_block, 10)
  master_ami               = var.master_backup_ami == "" ? lookup(local.ubuntu_amis, var.region, "") : var.master_backup_ami
  master_user_data         = var.master_backup_ami == "" ? data.template_file.init_master.rendered : ""
}

data "template_file" "init_master" {
  template = file("${path.module}/templates/${local.template_file}")
  vars = {
    ssh_authorized_key = tls_private_key.master.public_key_openssh
    cluster_name       = var.cluster_name
    cluster_version    = var.cluster_version
    public_ip          = aws_eip.master.public_ip
    join_token         = "${random_string.firts_part.result}.${random_string.second_part.result}"
    pod_network_cidr   = var.pod_network_cidr
    svc_network_cidr   = var.svc_network_cidr
    pgetcd_db_endpoint = local.pgetcd_db_endpoint
  }
}

resource "aws_eip" "master" {
  vpc = true
}

resource "random_string" "firts_part" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "second_part" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_spot_instance_request" "master" {
  ami                    = local.master_ami
  instance_type          = var.master_instance_type
  subnet_id              = data.aws_subnet.public.id
  vpc_security_group_ids = ["${aws_security_group.master.id}"]
  source_dest_check      = false
  user_data              = local.master_user_data
  private_ip             = local.master_private_static_ip
  root_block_device {
    volume_size = 100
  }
  spot_price           = lookup(local.sport_prices, var.master_instance_type, "")
  wait_for_fulfillment = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_spot_instance_request.master.spot_instance_id
  allocation_id = aws_eip.master.id
}
