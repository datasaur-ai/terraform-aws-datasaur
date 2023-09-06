resource "aws_elasticache_subnet_group" "redis" {
  name       = "eks-${var.cluster_name}-redis-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "allow_redis" {
  name   = "allow-redis-eks-${var.cluster_name}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.cluster_name}-redis-cluster"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.allow_redis.id]
  apply_immediately    = true

  # maintenance
  maintenance_window   = "mon:00:00-mon:01:00"

  tags = {
    Name                  = "${var.cluster_name}-redis-cluster"
    Environment           = var.environment

    VantaOwner            = var.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "Store in-memory data"
    VantaContainsUserData = true
    VantaUserDataStored   = "User session: emails. usernames. passwords." # TODO: update after https://github.com/vulcan-ai/vulcan/issues/6995 is resolved
    VantaContainsEPHI     = false
    VantaNoAlert          = var.vanta_no_alert_reason
  }
}
