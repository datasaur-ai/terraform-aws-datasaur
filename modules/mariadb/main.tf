resource "random_password" "password" {
  length = 16
  special = true
  override_special = "!#()-[]<>"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.cluster_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Project               = var.project
    Environment           = var.environment
    VantaOwner            = var.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "DB Subnet Group for RDS ${var.cluster_name}"
    VantaNoAlert          = var.vanta_no_alert_reason
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {  
  name = var.parameter_group_name
  family = var.parameter_group_family

  parameter {
    name = "max_allowed_packet"
    value = "134217728"
  }

  parameter {
    name = "slow_query_log"
    value = "1"
  }

  parameter {
    name = "binlog_format"
    value = "ROW"
  }

  parameter {
    name = "log_bin_trust_function_creators"
    value = "1"
  }
  
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Project               = var.project
    Environment           = var.environment
    VantaOwner            = var.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "DB Parameter Group for RDS ${var.cluster_name}"
    VantaNoAlert          = var.vanta_no_alert_reason
  }
}

resource "aws_db_instance" "vulcan" {
  identifier              = var.identifier
  allocated_storage       = var.db_allocated_storage
  storage_type            = "gp3"
  engine                  = local.engine
  engine_version          = var.engine_version
  instance_class          = var.db_instance_type
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids  = var.vpc_security_group_ids
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.password.result
  multi_az                = var.db_multi_az
  copy_tags_to_snapshot   = true
  storage_encrypted       = true
  
  parameter_group_name    = aws_db_parameter_group.db_parameter_group.name

  # maintenance
  maintenance_window              = "Sun:05:00-Sun:05:30"

  # logging
  enabled_cloudwatch_logs_exports = local.enabled_cloudwatch_logs_exports
  auto_minor_version_upgrade = true

  # backup
  backup_window           = "10:18-10:48"
  backup_retention_period = 14
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.identifier}-final-snapshot"

  tags = local.tags
}

resource "aws_db_instance" "vulcan-read-replica" {
  identifier              = "${var.identifier}-read-replica"
  replicate_source_db     = aws_db_instance.vulcan.identifier

  allocated_storage       = var.db_allocated_storage
  storage_type            = "gp3"
  engine                  = local.engine
  engine_version          = var.engine_version
  instance_class          = var.db_read_replica_instance_type

  # no subnet group because this is replica
  db_subnet_group_name    = null
  vpc_security_group_ids  = null
  
  # Username and password should not be set for replicas
  username = null
  password = null

  multi_az                = false

  storage_encrypted       = true
  parameter_group_name    = var.parameter_group_name

  backup_retention_period = 0

  # maintenance
  maintenance_window              = "Mon:05:00-Mon:05:30"

  # logging
  enabled_cloudwatch_logs_exports = local.enabled_cloudwatch_logs_exports

  skip_final_snapshot     = true
  deletion_protection     = false

  tags = local.tags
}