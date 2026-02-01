output "load_balancer_url" {
  description = "Public ALB URL"
  value       = aws_lb.public.dns_name
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.react_app.arn
}