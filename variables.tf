variable "region" {
  default = "ap-south-1"  # ✅ Mumbai region
}

variable "bucket_name" {
  default = "checkov-insecure-bucket-demo-02"
}

variable "environment" {
  default = "dev"
}

variable "ami_id" {
  # ✅ Amazon Linux 2 AMI for ap-south-1 (Mumbai)
  default = "ami-0cca134ec43cf708f"
}

variable "instance_type" {
  default = "t2.micro"
}
