# Add ssh key
data "digitalocean_ssh_key" "droplet_ssh_key" {
  name = "PastaKey"
}
