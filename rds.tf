resource "aws_rds_cluster" "this" {
  cluster_identifier_prefix       = "${var.id}-"
  final_snapshot_identifier       = "${var.id}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  copy_tags_to_snapshot           = true
  engine                          = "aurora"
  engine_mode                     = "serverless"
  database_name                   = "metabase"
  master_username                 = "root"
  master_password                 = random_string.this.result
  backup_retention_period         = 5 # days
  snapshot_identifier             = var.snapshot_identifier
  vpc_security_group_ids          = [aws_security_group.rds.id]
  db_subnet_group_name            = aws_db_subnet_group.this.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.id
  deletion_protection             = var.protection
  enable_http_endpoint            = true
  tags                            = var.tags

  scaling_configuration {
    min_capacity = 1
    max_capacity = var.max_capacity
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [snapshot_identifier,final_snapshot_identifier]
  }
}

resource "random_string" "this" {
  length  = 32
  special = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ssm_parameter" "this" {
  name        = var.id
  description = "RDS password"
  type        = "SecureString"
  value       = random_string.this.result
  tags        = var.tags
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "rds-db-credentials/${aws_rds_cluster.this.cluster_resource_id}/${var.id}"
  description             = "RDS credentials for use in query editor"
  recovery_window_in_days = 0
  tags                    = var.tags
}

locals {
  secret = {
    dbInstanceIdentifier = aws_rds_cluster.this.cluster_identifier
    engine               = aws_rds_cluster.this.engine
    dbname               = aws_rds_cluster.this.database_name
    host                 = aws_rds_cluster.this.endpoint
    port                 = aws_rds_cluster.this.port
    resourceId           = aws_rds_cluster.this.cluster_resource_id
    username             = aws_rds_cluster.this.master_username
    password             = random_string.this.result
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(local.secret)
}

resource "aws_db_subnet_group" "this" {
  name_prefix = "${var.id}-"
  subnet_ids  = tolist(var.private_subnet_ids)
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  name_prefix = "mb-"
  family      = "aurora5.6"
  tags        = var.tags

  parameter {
    name         = "lower_case_table_names"
    value        = "1"
    apply_method = "pending-reboot"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.id}-rds-"
  vpc_id      = var.vpc_id
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_ingress_ecs" {
  description              = "ECS"
  type                     = "ingress"
  from_port                = aws_rds_cluster.this.port
  to_port                  = aws_rds_cluster.this.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ecs.id
}
