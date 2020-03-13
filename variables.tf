variable "private_subnet_ids" {
  description = "(Required) IDs of the subnets to which the services and database will be deployed"
}

variable "public_subnet_ids" {
  description = "(Required) IDs of the subnets to which the load balancer will be deployed"
}

variable "domain" {
  description = "(Required) Domain where metabase will be hosted. Example: metabase.mycompany.com"
}

variable "zone_id" {
  description = "(Required) https://www.terraform.io/docs/providers/aws/r/route53_record.html#zone_id"
}

variable "certificate_arn" {
  description = "(Required) https://www.terraform.io/docs/providers/aws/r/lb_listener.html#certificate_arn"
}

variable "vpc_id" {
  description = "(Required) https://www.terraform.io/docs/providers/aws/r/security_group.html#vpc_id"
}

variable "id" {
  description = "(Optional) Unique identifier for naming resources"
  default     = "metabase"
}

variable "tags" {
  description = "(Optional) Tags applied to all resources"
  default     = {}
}

variable "image" {
  description = "(Optional) https://hub.docker.com/r/metabase/metabase"
  default     = "metabase/metabase"
}

variable "cpu" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html#cpu"
  default     = "512"
}

variable "memory" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html#memory"
  default     = "1920"
}

variable "max_capacity" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#max_capacity"
  default     = "16"
}

variable "desired_count" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/ecs_service.html#desired_count"
  default     = "2"
}

variable "log_retention" {
  description = "(Optional) Retention period in days for both ALB and container logs"
  default     = "90"
}

variable "protection" {
  description = "(Optional) Protect ALB and application logs from deletion"
  default     = false
}

variable "ssl_policy" {
  description = "(Optional) https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "snapshot_identifier" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#snapshot_identifier"
  default     = ""
}

variable "environment" {
  description = "(Optional) Additional container environment variables"
  default     = []
}
