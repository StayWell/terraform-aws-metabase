output "rds_security_group_id" {
  description = "https://www.terraform.io/docs/providers/aws/r/security_group.html#id"
  value       = aws_security_group.rds.id
}

output "rds_port" {
  description = "https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#port-1"
  value       = aws_rds_cluster.this.port
}
