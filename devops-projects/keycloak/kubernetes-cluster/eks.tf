data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "realworld-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  

  # because of sand box
  # create_cloudwatch_log_group = false
  # # create_kms_key = false  

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.medium"]
  }

  eks_managed_node_groups = {
    realworld-ng = {
      min_size     = 1
      max_size     = 5
      desired_size = 1
      iam_role_additional_policies = {
          ec2_access = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      }

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"
    }
  }

  

  iam_role_additional_policies = {
    ec2_access = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true


  tags = {
    Project = "realworld"
  }
}