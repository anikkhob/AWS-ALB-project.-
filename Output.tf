output "ALB_DNS_Name" {
    description = "The DNS name of the Application Load Balancer"
    value       = aws_lb.ALB.dns_name
}