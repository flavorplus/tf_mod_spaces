output "vpc_id" {
  value = aws_vpc.default.id
  description = "The VPC ID of the managed VPC."
}

output "subnet_id" {
  value = aws_subnet.default.id
  description = "The subnet that is managed and is part of the VPC."
}