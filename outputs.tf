output "rds_security_group_id" {
  description = "https://www.terraform.io/docs/providers/aws/r/security_group.html#id"
  value       = aws_security_group.rds.id
}

output "rds_port" {
  description = "https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#port-1"
  value       = aws_rds_cluster.this.port
}

output "listener_arn" {
  description = "https://www.terraform.io/docs/providers/aws/r/lb_listener.html#arn"
  value       = aws_lb_listener.https.arn
}

output "target_group_arn" {
  description = "https://www.terraform.io/docs/providers/aws/r/lb_target_group.html#arn"
  value       = aws_lb_target_group.this.arn
}
