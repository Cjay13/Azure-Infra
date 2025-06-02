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