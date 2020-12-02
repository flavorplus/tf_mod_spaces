//HashiCorp reaper specifick variables
variable "owner" {
  description = "IAM user responsible for lifecycle of cloud resources used for training"
}

variable "created-by" {
  description = "Tag used to identify resources created programmatically by Terraform"
  default     = "Terraform"
}

variable "sleep-at-night" {
  description = "Tag used by reaper to identify resources that can be shutdown at night"
  default     = true
}

variable "TTL" {
  description = "Hours after which resource expires, used by reaper. Do not use any unit. -1 is infinite."
  default     = "240"
}

//Rest of the VARS
variable "ssh_public_key" {
  description = "The SSH public key to be used for authentication to the EC2 instances."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-central-1"
}

