locals {
  cluster_name = "${var.deployment_prefix}-eks-cluster"
}

data "aws_caller_identity" "current" {}

module "eks" { 
  source = "terraform-aws-modules/eks/aws"
  version = "21.5.0"
  
  name              = local.cluster_name
  kubernetes_version = "1.34"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnets
  enable_irsa       = true
  endpoint_private_access = true
  endpoint_public_access  = true

  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    management = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 40 
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      key_name = "key-us-east-1"
      
      vpc_security_group_ids = [
        aws_security_group.all_worker_node_groups.id
        ]
      
      labels = {
        "node.k8s/role" = "management"
      }
      
      timeouts = {
        create = "45m"
        update = "30m"
        delete = "40m"
      }
    }
  }
  

  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      source_cluster_security_group = true
      description                   = "Allow workers pods to receive communication from the cluster control plane."
    }
    ingress_self_all = {
      description = "Allow nodes to communicate with each other (all ports/protocols)."
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress."
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}