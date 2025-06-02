variable "resource_group_name" {
    type = string
    description = "Resource group name"
    default = "user-management"
}

variable "vnet_cidr_range" {
  type = string
  description = "Address space of the vnet"
  default = "10.1.0.0/22"
}

variable "aks_subnet_cidr_range" {
  type = string
  description = "Address space of the AKS subnet"
  default = "10.1.0.0/23"
}

variable "db_subnet_cidr_range" {
  type = string
  description = "Address space of the DB subnet"
  default = "10.1.2.0/27"
}

variable "appgw_subnet_cidr_range" {
  type = string
  description = "Address space of the Application GW subnet"
  default = "10.1.2.32/27"
}

variable "db_port" {
  type = number
  description = "DB port"
  default = 5432
}

variable "argocd_namespace" {
  description = "Namespace where argocd will be installed"
  type = string
  default = "argocd"
}

variable "argocd_domainName" {
  description = "Doamin name for argocd ui"
  type = string
  default = "argocd.cjaydevops.com"
}

variable "argocd_enable_ingress" {
  description = "Whether to enable ingress for argocd or not"
  type = bool
  default = true
}

variable "argocd_enable_tls" {
  description = "Whether to enable TLS termination at ingress for argocd or not"
  type = bool
  default = false
}

variable "ingress_class_name" {
  description = "Name of the ingressClass"
  type = string
  default = "azure-application-gateway"
}