output "backend_url" {
  description = "Public URL of the backend API"
  value       = "http://${aws_eip.backend.public_ip}:8080"
}

output "ec2_public_ip" {
  description = "Elastic IP of the EC2 instance"
  value       = aws_eip.backend.public_ip
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint (private, reachable only from EC2)"
  value       = aws_db_instance.postgres.address
}

output "ssh_command" {
  description = "Command to SSH into the EC2 instance"
  value       = "ssh -i ${var.ssh_private_key_path} ubuntu@${aws_eip.backend.public_ip}"
}

output "eks_cluster_name" {
  description = "EKS cluster name — use as EKS_CLUSTER_NAME in GitHub secrets"
  value       = aws_eks_cluster.main.name
}

output "eks_kubeconfig_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
