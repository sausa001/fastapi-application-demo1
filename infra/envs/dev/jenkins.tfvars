#
create_vpc    = true          # standalone; set false + existing_vpc_name to reuse a VPC
vpc_cidr      = "10.10.0.0/16"
instance_type = "t3.medium"
key_name      = ""            # optional EC2 key pair name
allowed_cidrs = [
  "122.187.156.67/32",      # curl -s ifconfig.me
  # GitHub webhook ranges (check current list: curl -s https://api.github.com/meta | jq .hooks)
  "192.30.252.0/22", "185.199.108.0/22", "140.82.112.0/20", "143.55.64.0/20",
]
