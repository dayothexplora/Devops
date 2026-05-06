variable "instance_name" {
  description = "Name tag of the EC2 instance"
  type        = string
  default     = "Developer"
}

variable "instance_type" {
  description = " The Ec2 Instance type"
  type        = string
  default     = "t2.micro" # Free tier eligible instance type
}

variable "instance_count" {
  description = "Number of Instances to Create"
  default     = 2 # Adjust number of instances to create.
}

variable "bucket_name" {
  description = " name and tag of bucket"
  type        = string
  default     = "portfolio-bucket-2026"
}

variable "environment" {
  description = "Enviroment name for s3 bucket"
  type        = string
  default     = "dev"
}
