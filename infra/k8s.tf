resource "minikube_cluster" "docker" {
	cluster_name = var.client
	nodes = 1
}