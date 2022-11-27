# Create a new VPC
resource "digitalocean_vpc" "web_vpc" {
  name   = "4640-labs"
  region = var.region
}

