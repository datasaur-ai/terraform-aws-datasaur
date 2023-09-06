output "db_password" {
  value = "${random_password.password.result}"
  sensitive = true
}

output "db_username" {
  value = var.db_username
}

output "db_name" {
  value = var.db_name
}

output "endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.vulcan.endpoint
}
