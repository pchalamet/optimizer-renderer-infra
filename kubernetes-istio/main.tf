provider "google-beta" {
  credentials = "${file("../secrets/account.json")}"
  project = "${var.gcp_project}"
  region = "${var.gcp_region}"
}

provider "kubernetes" {
  host = "https://${google_container_cluster.gke_cluster.endpoint}"
  username = "${var.master_username}"
  password = "${var.master_password}"

  client_certificate = "${base64decode(google_container_cluster.gke_cluster.master_auth.0.client_certificate)}"
  client_key = "${base64decode(google_container_cluster.gke_cluster.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)}"
}

resource "google_container_cluster" "gke_cluster" {
  provider = "google-beta"
  name = "${var.cluster_name}"
  zone = "${var.gcp_region}-a"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.  remove_default_node_pool = true
  initial_node_count = 1
  
  additional_zones = []

  master_auth {
    username = "${var.master_username}"
    password = "${var.master_password}"
  }

  addons_config {
    istio_config {
      disabled = false
    }
    kubernetes_dashboard {
      disabled = false
    }
  }
}

resource "google_container_node_pool" "gke_node_pool" {
  provider = "google-beta"
  name = "${var.cluster_name}-pool"
  # region = "${var.gcp_region}"
  zone = "${var.gcp_region}-a"
  cluster = "${google_container_cluster.gke_cluster.name}"
  node_count = "${var.min_node_count}"

  autoscaling {
    min_node_count = "${var.min_node_count}"
    max_node_count = "${var.max_node_count}"
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
