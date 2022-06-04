// Resource: https://github.com/istio/istio/tree/master/manifests/charts/base
resource "helm_release" "istio-base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.12.1"
  namespace  = "istio-system"
  depends_on = [kubernetes_namespace.istio-system]
}

// Resource: https://github.com/istio/istio/tree/master/manifests/charts/istio-control/istio-discovery
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.12.1"
  namespace  = "istio-system"
  depends_on = [
    helm_release.istio-base
  ]

  set {
    name  = "pilot.autoscaleMin"
    value = 1
  }
}

// Resource: https://github.com/istio/istio/tree/master/manifests/charts/gateway
resource "helm_release" "istio-ingressgateway" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.12.1"
  namespace  = "istio-system"
  depends_on = [
    helm_release.istiod
  ]

  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "autoscaling.minReplicas"
    value = 1
  }
}

// Resource: https://artifacthub.io/packages/helm/aws/aws-node-termination-handler
resource "helm_release" "aws-node-termination-handler" {
  name       = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  version    = "0.15.3"
  namespace  = "kube-system"
}

// Resource: https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler
resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.10.6"
  namespace  = "kube-system"

  set {
    name  = "rbac.create"
    value = true
  }
  set {
    name  = "cloudProvider"
    value = "aws"
  }
  set {
    name  = "awsRegion"
    value = "us-east-1"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_name
  }
}

// Resource: https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.2.7"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_name
  }
  set {
    type  = "string"
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.terraform_remote_state.eks.outputs.alb_iam_arn
  }
}

// Resource: https://github.com/kubernetes-sigs/metrics-server/tree/master/charts/metrics-server
# resource "helm_release" "metrics-server" {
#   name       = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   version    = "3.7.0"
#   namespace  = "kube-system"
# }

