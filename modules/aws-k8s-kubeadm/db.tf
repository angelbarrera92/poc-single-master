resource "aws_security_group" "db" {
  count       = var.external_db == true ? 1 : 0
  vpc_id      = data.aws_vpc.vpc.id
  name_prefix = "${var.cluster_name}-db"
}

resource "aws_security_group_rule" "db_ingress" {
  count                    = var.external_db == true ? 1 : 0
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.master.id
  security_group_id        = aws_security_group.db[0].id
}

resource "aws_security_group_rule" "db_egress" {
  count             = var.external_db == true ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db[0].id
}

resource "aws_db_subnet_group" "db" {
  count      = var.external_db == true ? 1 : 0
  name       = "pgetcd"
  subnet_ids = ["${var.private_subnet_id}", "${var.public_subnet_id}"]
}

resource "random_string" "db_password" {
  count   = var.external_db == true ? 1 : 0
  length  = 16
  special = false
  upper   = false
}

resource "aws_db_instance" "db" {
  count                  = var.external_db == true ? 1 : 0
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "9.6"
  instance_class         = var.rds_instance_type
  identifier_prefix      = "pgetcd"
  name                   = "pgetcd"
  username               = "pgetcd"
  skip_final_snapshot    = true
  apply_immediately      = true
  password               = random_string.db_password[0].result
  parameter_group_name   = "default.postgres9.6"
  vpc_security_group_ids = [aws_security_group.db[0].id]
  db_subnet_group_name   = aws_db_subnet_group.db[0].id
}
