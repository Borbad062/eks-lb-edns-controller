# Data source для получения токена аутентификации
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

# Helm релиз с прямым указанием репозитория
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.17.0"
  namespace  = local.k8s_service_account_lb_namespace

  set = [
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = module.vpc.vpc_id
    },
    {
      name  = "clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "serviceAccount.name"
      value = local.k8s_service_account_lb_name
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.iam_assumable_role_aws_load_balancer_controller.iam_role_arn
    }
  ]

  depends_on = [
    module.eks,
    data.aws_eks_cluster_auth.this
  ]
}

# 4. Установка ExternalDNS через Helm-провайдер
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.19.0"
  namespace  = local.k8s_service_account_lb_namespace
  atomic     = true

  set = [
  {
    name  = "provider"
    value = "aws"
  },

  
  {
    name  = "aws.region"
    value = var.aws_region
  },

  {
    name  = "aws.zoneType"
    value = "public"
  },

  {
    name  = "domainFilters[0]"
    value = "zubaidov.com"
  },

  {
    name  = "policy"
    value = "sync"
  },

  {
    name  = "registry"
    value = "txt"
  },

  {
    name  = "txtOwnerId"
    value = "my-demo-identifier"
  },

  {
    name  = "sources[0]"
    value = "service"
  },

  {
    name  = "sources[1]"
    value = "ingress"
  },

  # Конфигурация Service Account
  {
    name  = "serviceAccount.create"
    value = "true"
  },

  {
    name  = "serviceAccount.name"
    value = "external-dns"
  },

  {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_external_dns.iam_role_arn
  }

  ]
  # Зависимости: ждем создания кластера и IAM роли
  depends_on = [
    module.eks,
    module.iam_assumable_role_external_dns
  ]
}