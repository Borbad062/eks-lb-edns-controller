### 3. **eks-lb-edns-controller** (AWS Load Balancer Controller + ExternalDNS)

```markdown
# AWS Load Balancer Controller + ExternalDNS on EKS

Настройка **AWS Load Balancer Controller** и **ExternalDNS** для автоматического управления трафиком и DNS записями в AWS.

## 🎯 Цель проекта
- Автоматическое создание AWS Load Balancer при создании Ingress/Service типа LoadBalancer
- Автоматическое создание DNS записей в Route53 для Ingress ресурсов

## 🛠 Технологии
- **AWS Load Balancer Controller** — управление ALB/NLB в AWS
- **ExternalDNS** — синхронизация Ingress/Service с Route53
- **Amazon EKS** — управляемый кластер Kubernetes
- **IAM Roles for Service Accounts (IRSA)** — безопасный доступ к AWS
- **Helm** — установка контроллеров

## 📋 Предварительные требования
- Кластер EKS
- Доменная зона в Route53
- IAM OIDC провайдер для кластера
