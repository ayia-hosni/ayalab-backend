variable "aws_region" {
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key content (paste the contents of ~/.ssh/id_rsa.pub)"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to your SSH private key on this machine"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "frontend_origin" {
  description = "Allowed CORS origin (your frontend URL)"
  type        = string
  default     = "*"
}

variable "app_version" {
  description = "Version from pom.xml — used to locate the built JAR"
  type        = string
  default     = "1.0.0"
}
