provider "aws" {
  region = "us-east-2" # Replace with your desired AWS region
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] # Replace with the desired Ubuntu version
  }
  owners = ["099720109477"]
}

resource "aws_instance" "host_server" {
  count                  = var.instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.portfolio_subnet.id
  vpc_security_group_ids = [aws_security_group.portfolio_sg.id]
  key_name               = aws_key_pair.portfolio_kp.key_name

  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }
}

resource "aws_security_group" "portfolio_sg" {
  name        = "portfolio-sg"
  description = "Security group for portfolio EC2 instances"
  vpc_id      = aws_vpc.portfolio_vpc.id

  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  #ALlow SMTP access from anywhere
  ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow SMTPS access from anywhere
  ingress {
    from_port   = 465
    to_port     = 465
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow Kubernetes API access from anywhere
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow NodePort access from anywhere
  ingress {
    from_port   = 3000
    to_port     = 10000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow NodePort access from anywhere
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-sg" }
}


# Create a VPC
resource "aws_vpc" "portfolio_vpc" {
  cidr_block           = "10.100.0.0/16" # Replace with your desired CIDR block
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "portfolio-vpc"
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "portfolio_subnet" {
  vpc_id                  = aws_vpc.portfolio_vpc.id
  cidr_block              = "10.100.100.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name = "portfolio-subnet"
  }
}

# Internet Gateway — for instances access from the internet
resource "aws_internet_gateway" "portfolio_igw" {
  vpc_id = aws_vpc.portfolio_vpc.id

  tags = {
    Name = "portfolio-igw"
  }
}

# Route table — sends all traffic through the IGW
resource "aws_route_table" "portfolio_rt" {
  vpc_id = aws_vpc.portfolio_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.portfolio_igw.id
  }

  tags = {
    Name = "portfolio-rt"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "portfolio_rta" {
  subnet_id      = aws_subnet.portfolio_subnet.id
  route_table_id = aws_route_table.portfolio_rt.id
}


# Create a s3 bucket to store portfolio static site files.
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = "portfolio-bucket"
    environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "portfolio_bucket_website" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "portfolio_bucket_public_access" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "portfolio_bucket_policy" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["<<your-account-id>>"] # Replace with the actual AWS account ID that needs access
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.portfolio_bucket.arn,
      "${aws_s3_bucket.portfolio_bucket.arn}/*",
    ]
  }
}


# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "portfolio_bucket_versioning" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "portfolio_bucket_encryption" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

}


