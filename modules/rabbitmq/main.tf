resource "random_password" "console_password" {
  length = 16
  special = true
  override_special = "!#()-[]<>"
}

resource "aws_mq_broker" "broker" {
  broker_name = var.broker_name

  engine_type        = "RabbitMQ"
  engine_version     = "3.10.20"
  storage_type       = "ebs"
  host_instance_type = var.instance_type
  security_groups    = var.security_group_ids
  subnet_ids         = var.subnet_ids
  deployment_mode    = var.deployment_mode

  # maintenance
  maintenance_window_start_time {
    day_of_week = "MONDAY"
    time_of_day = "00:00"
    time_zone   = "UTC"
  }

  user {
    username = local.username
    password = random_password.console_password.result
  }

  logs {
    audit   = false
    general = true
  }
}