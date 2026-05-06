# Generate the private key
resource "tls_private_key" "portfolio_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair using the public key
resource "aws_key_pair" "portfolio_kp" {
  key_name   = "portfolio-key"
  public_key = tls_private_key.portfolio_key.public_key_openssh

  tags = {
    Name = "portfolio-key"
  }
}

# Save the private key to a local .pem file
resource "local_file" "private_key" {
  content         = tls_private_key.portfolio_key.private_key_pem
  filename        = "${path.module}/portfolio-key.pem"
  file_permission = "0400" # read only — same as chmod 400
}
