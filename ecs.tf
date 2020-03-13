resource "aws_ecs_cluster" "this" {
  name               = var.id
  capacity_providers = ["FARGATE"]
  tags               = var.tags

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.id
  container_definitions    = jsonencode(local.container)
  requires_compatibilities = "FARGATE"
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = var.tags
}

resource "aws_ecs_service" "this" {
  name            = var.id
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  propagate_tags  = "SERVICE"
  tags            = var.tags

  load_balancer {
    target_group_arn = aws_lb_target_group.this.id
    container_name   = local.container.name
    container_port   = local.container.portMappings.containerPort
  }

  network_configuration {
    security_groups = [aws_security_group.ecs.id]
    subnets         = tolist(var.private_subnet_ids)
  }
}

data "aws_region" "this" {}

locals {
  container = {
    name        = "metabase"
    image       = var.image
    essential   = true
    environment = merge(local.environment, var.environment)

    portMappings = {
      containerPort = 3000
    }

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.metabase.name
        awslogs-region        = data.aws_region.this.name
        awslogs-stream-prefix = "ecs"
      }
    }
  }

  environment = {
    MB_DB_TYPE   = "mysql"
    MB_DB_DBNAME = aws_rds_cluster.this.database_name
    MB_DB_PORT   = aws_rds_cluster.this.port
    MB_DB_USER   = aws_rds_cluster.this.master_username
    MB_DB_PASS   = random_string.this.result
    MB_DB_HOST   = aws_rds_cluster.this.endpoint
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.id
  port        = local.container.portMappings.containerPort
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header = [var.domain]
  }
}

resource "aws_route53_record" "this" {
  name    = var.domain
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.id
  retention_in_days = var.log_retention
  tags              = var.tags
}

resource "aws_security_group" "ecs" {
  name_prefix = "${var.id}-ecs-"
  vpc_id      = var.vpc_id
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ecs_egress_internet" {
  description       = "Internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_ingress_alb" {
  description              = "ALB"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.ecs.id
  source_security_group_id = aws_security_group.alb.id
}
