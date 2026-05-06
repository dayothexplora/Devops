output "instance_hostname" {
  description = "Private DNS name of  all the EC2 instances."
  value       = aws_instance.host_server[*].private_dns
}

output "private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to the private key file"
}

output "key_pair_name" {
  value       = aws_key_pair.portfolio_kp.key_name
  description = "AWS key pair name"
}

output "instance_public_ip" {
  description = "Public IP addresses of all the EC2 instances."
  value       = aws_instance.host_server[*].public_ip
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.portfolio_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.portfolio_bucket.arn
}

output "bucket_region" {
  description = "Region where the S3 bucket is created"
  value       = aws_s3_bucket.portfolio_bucket.region
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.portfolio_bucket.bucket_domain_name
}
