output "endpoint" {
  value = aws_mq_broker.broker.instances.0.endpoints
}

output "username" {
  value = local.username
}

output "password" {
  value = random_password.console_password
  sensitive = true
}
