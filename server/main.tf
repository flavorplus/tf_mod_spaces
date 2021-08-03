terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

provider "vault" {
  address = var.vault_addr
  token = var.vault_token
}

provider "random" {
  version = "3.0.0"
}

resource "random_pet" "name" {
  length = 2
  prefix = "TF-Modules_and_workspaces-server-"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    owner           = var.owner
    created-by      = var.created-by
    sleep-at-night  = var.sleep-at-night
    TTL             = var.TTL
  }
}

resource "aws_key_pair" "default" {
  key_name   = "${random_pet.name.id}-ssh_public_key"
  public_key = var.ssh_public_key
}



data "terraform_remote_state" "network" {
  backend = "remote"
  config = {
    organization = "joni-test"
    workspaces = {
      name = "modules_and_outputs-network"
    }
  }
}

data "aws_ami" "base" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "server" {
  ami                         = data.aws_ami.base.id
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = data.terraform_remote_state.network.outputs.subnet_id
  vpc_security_group_ids      = [aws_security_group.server.id]
  user_data                   = file("./nginx.sh")
  key_name                    = aws_key_pair.default.id
  
  tags                        = merge(local.common_tags, { Name = "${random_pet.name.id}-server" })
}

resource "aws_security_group" "server" {
  name   = "${random_pet.name.id}-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "vault_generic_secret" "secret" {
  path = var.vault_path
}

output "secret" {
  value = nonsensitive(data.vault_generic_secret.secret.data)
  description = "The secret retreived from the Vault server."
}