module "k8s_cluster" {
  source = "./kubernetes-istio"

  gcp_project = "optimizedrenderer"
  gcp_region = "us-east4"
  
  cluster_name = "optimizer"
  cluster_region = "us-east4"
  min_node_count = 2
  max_node_count = 3
  master_username = "admin"
  master_password = "${var.master_password}"

  helm_repository = "https://chart-repo.storage.googleapis.com"
}
