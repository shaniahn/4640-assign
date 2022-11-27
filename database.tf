# Adding database cluster
resource "digitalocean_database_cluster" "mongodb-cluster" {
  name       = "mongo-cluster"
  engine     = "mongodb"
  version    = "4"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1

  private_network_uuid = digitalocean_vpc.web_vpc.id
}

# Creating a firewall for the database where only machines tagged with Web can access the db
resource "digitalocean_database_firewall" "fw" {
  cluster_id = digitalocean_database_cluster.mongodb-cluster.id

  rule {
    type  = "tag"
    value = digitalocean_tag.do_tag.name
  }
}
