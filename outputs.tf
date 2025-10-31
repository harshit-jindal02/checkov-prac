output "instance_id" {
  value = aws_instance.insecure_instance.id
}

output "bucket_name" {
  value = aws_s3_bucket.insecure_bucket.bucket
}
