output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "EKS' Node Shared Security Group"
  value       = module.eks.node_security_group_id
}

output "vpc_id" {
  description = "VPC Id"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC Cidr Block"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_private_subnet_ids" {
  description = "VPC private subnet ids"
  value       = module.vpc.private_subnets
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}
