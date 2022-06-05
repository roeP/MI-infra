resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "mi" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }
    name = "mi"
  }
}

resource "kubernetes_ingress" "istio_ingress" {
  metadata {
    name      = "eks-alb-istio"
    namespace = "istio-system"
    annotations = {
      "kubernetes.io/ingress.class"                        = "alb"
      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
      "alb.ingress.kubernetes.io/success-codes"            = "200,404"
      "alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "deletion_protection.enabled=true"
      "alb.ingress.kubernetes.io/load-balancer-name"       = "mi-eks-alb-istio"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = "istio-ingressgateway"
            service_port = 80
          }
          path = "/*"
        }
      }
    }
  }
  depends_on = [
    helm_release.istio-ingressgateway
  ]
}

resource "kubernetes_config_map" "aws-auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<ROLES
- rolearn: arn:aws:iam::699826842731:role/mi-worker-role
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
ROLES
    mapUsers = <<USERS
- userarn: arn:aws:iam::699826842731:user/terraform
  username: terraform
  groups:
    - system:masters
USERS
  }
}