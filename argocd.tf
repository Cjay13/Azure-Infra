# module "argocd" {
#     source = "git::https://github.com/Cjay13/terraform-k8s-argocd.git?ref=main"
#     namespace = var.argocd_namespace
#     enable_ingress = var.argocd_enable_ingress
#     ingressClassName = var.ingress_class_name
#     enable_tls = var.argocd_enable_tls
#     domainName = var.argocd_domainName
# }