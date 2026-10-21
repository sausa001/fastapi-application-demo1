#
create_vpc          = false
existing_vpc_name   = "fastapi-application-demo1-dev-vpc"   # created by the vpc stack
kubernetes_version  = "1.34"                    # check `aws eks describe-cluster-versions` for supported versions
node_instance_types = ["t3.medium"]
node_desired        = 2