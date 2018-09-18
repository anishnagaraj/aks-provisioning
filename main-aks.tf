resource "azurerm_resource_group" "k8s" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.k8s.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  dns_prefix          = "${var.dns_prefix}"
  kubernetes_version  = "${var.kube_version}"

  linux_profile {
    admin_username = "${var.admin_username}"

    ssh_key {
      key_data = "${file("/aks-terraform/id_rsa.pub")}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.min_agent_count}"
    vm_size         = "${var.azurek8s_sku}"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }
}

resource "null_resource" "provision" {

  provisioner "local-exec" {
    command = "az aks get-credentials -n ${azurerm_kubernetes_cluster.k8s.name} -g ${azurerm_kubernetes_cluster.k8s.resource_group_name}"
  }

  provisioner "local-exec" {
    command = "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl;"
  }

  provisioner "local-exec" {
    command = "chmod +x ./kubectl;"
  }

  provisioner "local-exec" {
    command = "mv ./kubectl /usr/local/bin/kubectl;"
  }

  provisioner "local-exec" {
    command = "curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh"
  }

  provisioner "local-exec" {
    command = "chmod 700 get_helm.sh"
  }

  provisioner "local-exec" {
    command = "./get_helm.sh"
  }

  provisioner "local-exec" {
    command = "kubectl config use-context ${azurerm_kubernetes_cluster.k8s.name}"
  }

  provisioner "local-exec" {
    command = "helm init --upgrade"
  }

  provisioner "local-exec" {
    command = "kubectl create -f helm-rbac.yaml"
  }

  provisioner "local-exec" {
    command = "bash cluster-autoscaler-using-sed.sh cluster_name=${azurerm_kubernetes_cluster.k8s.name} resource_group=${azurerm_kubernetes_cluster.k8s.resource_group_name} min_nodes=${var.min_agent_count} max_nodes=1${var.max_agent_count}"
  }

   provisioner "local-exec" {
    command = <<EOF
            sleep 60
      EOF
  }

  provisioner "local-exec" {
    command = "rm terraform.tfstate"
  }

  provisioner "local-exec" {
    command = "rm get_helm.sh"
  }

  provisioner "local-exec" {
    command = "rm run.plan"
  }

}
