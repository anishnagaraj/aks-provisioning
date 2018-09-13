variable "resource_group_name" {
  description = "Please input a new Azure Resource group name "
}

variable "location" {
  description = "Please input the Azure region for deployment - for e.g: westeurope or eastus "
}


variable "cluster_name" {
  description = "Please input the k8s cluster name to create"
}

variable "dns_prefix" {
  description = "Please input the DNS prefix to create"
}

variable "kube_version" {
  description = "Please input the k8s version -  1.11.2 is the latest in westeurope or eastus"
}

variable "min_agent_count" {
  description = "Number of Minimum Cluster Agent Nodes - Please view https://docs.microsoft.com/en-us/azure/aks/faq#are-security-updates-applied-to-aks-agent-nodes"
}

variable "max_agent_count" {
  description = "Number of Maximum Cluster Agent Nodes - Please view https://docs.microsoft.com/en-us/azure/aks/faq#are-security-updates-applied-to-aks-agent-nodes"
}

variable "azurek8s_sku" {
  default = "Standard_F2s"
}

variable "client_id" {
  description = "Please input the Azure Application ID known as client_id"
}

variable "client_secret" {
  description = "Please input the Azure client secret for the Azure Application ID known as client_id"
}

variable "admin_username" {
  default = "aksadmin"
}
