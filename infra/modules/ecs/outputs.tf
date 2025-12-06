output "load_balancer_url" {
  description = "Public ALB URL"
  value       = aws_lb.public.dns_name
}
