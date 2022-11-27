# Print public IP addresses of all droplets
output "droplets_public_ip_address" {
  value = flatten([digitalocean_droplet.Web.*.ipv4_address])
}

# Print IP address of Bastion Server
output "bastion_ip_address" {
  value = digitalocean_droplet.bastion.ipv4_address
}

# Print IP addresss of db
output "database_ip_address" {
  value = digitalocean_database_cluster.mongodb-cluster.urn
}

# Print IP address of load balancer
output "lb_ip_address" {
  value = digitalocean_loadbalancer.public.ip
}
