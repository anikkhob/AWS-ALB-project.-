variable "aws-region" {
    description = "AWS region to deploy resources"
    type = string
    default = "ap-south-1"
}


variable "vpc-cidr" {
    description = "CIDR Block for VPC"
    type = string
    default = "10.0.0.0/16" 
}
