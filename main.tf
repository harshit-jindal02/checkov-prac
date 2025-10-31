provider "aws" {
  region = var.region
}

# ❌ Intentionally insecure S3 bucket (for Checkov testing)
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = var.bucket_name

  # Removed "acl" (handled below in separate resource)
  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

# ⚠️ Public-read ACL applied via separate resource (still insecure)
resource "aws_s3_bucket_acl" "insecure_bucket_acl" {
  bucket = aws_s3_bucket.insecure_bucket.id
  acl    = "public-read"  # CKV_AWS_145 (still intentionally insecure)
}

# ❌ Insecure EC2 instance
resource "aws_instance" "insecure_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Using default security group (CKV_AWS_88)
  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    # encryption disabled (CKV_AWS_8)
  }

  tags = {
    Name = "checkov-insecure-instance"
  }
}
