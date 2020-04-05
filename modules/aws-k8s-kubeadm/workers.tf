resource "aws_security_group" "worker" {
  vpc_id      = data.aws_vpc.vpc.id
  name_prefix = "${var.cluster_name}-worker"
}

resource "aws_security_group_rule" "worker_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_ingress_nodeport" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.worker.id
}


resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

data "template_file" "init_worker" {
  template = file("${path.module}/templates/worker.tpl.yaml")
  vars = {
    ssh_authorized_key = tls_private_key.master.public_key_openssh
    cluster_name       = var.cluster_name
    cluster_version    = var.cluster_version
    master_private_ip  = local.master_private_static_ip
    join_token         = "${random_string.firts_part.result}.${random_string.second_part.result}"
  }
}

resource "aws_spot_instance_request" "worker" {
  count                  = var.worker_count
  ami                    = lookup(local.ubuntu_amis, var.region, "")
  instance_type          = var.worker_instance_type
  subnet_id              = data.aws_subnet.private.id
  vpc_security_group_ids = ["${aws_security_group.worker.id}"]
  source_dest_check      = false
  user_data              = data.template_file.init_worker.rendered
  root_block_device {
    volume_size = 100
  }
  spot_price           = lookup(local.sport_prices, var.worker_instance_type, "")
  wait_for_fulfillment = true
}
