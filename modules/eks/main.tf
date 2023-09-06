
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = var.cluster_name

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  # flow log
  create_flow_log_cloudwatch_iam_role = false
  create_flow_log_cloudwatch_log_group = false
  enable_flow_log = true
  flow_log_cloudwatch_iam_role_arn = var.vpc_flow_log_cloudwatch_iam_role_arn
  flow_log_max_aggregation_interval = 600
  flow_log_destination_arn = var.vpc_flow_log_cloudwatch_destination_arn
  flow_log_destination_type = "cloud-watch-logs"
  flow_log_traffic_type = "ALL"


  tags = {
    Name                  = "VPC for customer ${var.customer_name}"
    Environment           = var.environment
    Description           = var.description
    Project               = var.project
    VantaOwner            = var.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "VPC for customer ${var.customer_name}"
    VantaContainsUserData = false
    VantaContainsEPHI     = false
  }
}

resource "aws_iam_policy" "datasaur_node_group_policy" {
  name  = "datasaur-${var.cluster_name}-nodegroup-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
            "Sid": "SessionTokenServiceAssumeRole",
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/datasaur/${var.cluster_name}/*"
        }
    ]
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = var.cluster_name
  cluster_version = "1.26"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "standard-worker-1"

      instance_types = var.node_group_worker_instance_types

      min_size     = 1
      max_size     = var.node_group_worker_max_size
      desired_size = var.node_group_worker_desired_size

       iam_role_additional_policies = {      
        DatasaurNodeGroupPolicy = aws_iam_policy.datasaur_node_group_policy.arn
      }
    }
  }

  cloudwatch_log_group_retention_in_days = 365

  # tags
  tags = {
    Name                  = "EKS for customer ${var.customer_name}"
    Environment           = var.environment
    Description           = var.description
    Project               = var.project
    VantaOwner            = var.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "EKS for customer ${var.customer_name}"
    VantaContainsUserData = false
    VantaContainsEPHI     = false
  }
}
    

# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.17.0-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
    Name                  = "EBS CSI for customer ${var.customer_name}"
    Environment           = var.environment
    Description           = var.description
    Project               = var.project
    VantaOwner            = var.owner
    VantaNonProd          = var.non_prod
    VantaDescription      = "EBS CSI for customer ${var.customer_name}"
    VantaContainsUserData = false
    VantaContainsEPHI     = false
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "nginx" {
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  namespace  = "ingress-nginx"
  create_namespace = true

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}
