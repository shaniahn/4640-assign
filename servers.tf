# Create a new tag
resource "digitalocean_tag" "do_tag" {
  name = "Web"
}

# Create new Web Droplets
resource "digitalocean_droplet" "Web" {
  image    = "rockylinux-9-x64"
  count    = var.droplet_count
  name     = "web-${count.index + 1}"
  region   = var.region
  size     = "s-1vcpu-512mb-10gb"
  tags     = [digitalocean_tag.do_tag.id]
  ssh_keys = [data.digitalocean_ssh_key.droplet_ssh_key.id]
  vpc_uuid = digitalocean_vpc.web_vpc.id

  lifecycle {
    create_before_destroy = true
  }
}


# Add load balancer
resource "digitalocean_loadbalancer" "public" {
  name     = "loadbalancer-1"
  region   = var.region
  vpc_uuid = digitalocean_vpc.web_vpc.id

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }
}

resource "digitalocean_firewall" "web" {

  # The name we give our firewall for ease of use                            #    
  name = "web-firewall"

  # The droplets to apply this firewall to                                   #
  droplet_ids = digitalocean_droplet.Web.*.id

  # Internal VPC Rules. We have to let ourselves talk to each other
  inbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    source_addresses = [digitalocean_vpc.web_vpc.ip_range]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "1-65535"
    source_addresses = [digitalocean_vpc.web_vpc.ip_range]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = [digitalocean_vpc.web_vpc.ip_range]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = [digitalocean_vpc.web_vpc.ip_range]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = [digitalocean_vpc.web_vpc.ip_range]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = [digitalocean_vpc.web_vpc.ip_range]

    # Selective Outbound Traffic Rules

    # HTTP
    outbound_rule {
      protocol              = "tcp"
      port_range            = "80"
      destination_addresses = [digitalocean_loadbalancer.public.ip]
    }
    # HTTPS
    outbound_rule {
      protocol              = "tcp"
      port_range            = "443"
      destination_addresses = [digitalocean_loadbalancer.public.ip]
    }

    # ICMP (Ping)
    outbound_rule {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
}
